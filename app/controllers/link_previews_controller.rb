require "open-uri"

class LinkPreviewsController < ApplicationController
  TIMEOUT = 5
  PRIVATE_RANGES = [
    /\A127\./,
    /\A10\./,
    /\A192\.168\./,
    /\A172\.(1[6-9]|2\d|3[01])\./,
    /\Alocalhost\z/i,
    /\A::1\z/
  ].freeze

  OEMBED_PROVIDERS = {
    /youtube\.com|youtu\.be/ => "https://www.youtube.com/oembed?url=%s&format=json",
    /vimeo\.com/             => "https://vimeo.com/api/oembed.json?url=%s"
  }.freeze

  def show
    url = params[:url].to_s.strip
    uri = URI.parse(url)
    return head :bad_request unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    return head :bad_request if private_host?(uri.host)

    data = Rails.cache.fetch("lp:#{Digest::SHA1.hexdigest(url)}", expires_in: 24.hours) do
      fetch_og(url)
    end

    render json: data
  rescue URI::InvalidURIError, ArgumentError
    head :bad_request
  rescue => e
    Rails.logger.warn "LinkPreview fetch error for #{params[:url]}: #{e.message}"
    render json: { error: true }
  end

  private

  def private_host?(host)
    return true if host.blank?
    PRIVATE_RANGES.any? { |r| host.match?(r) }
  end

  def fetch_og(url)
    OEMBED_PROVIDERS.each do |pattern, endpoint_template|
      next unless url.match?(pattern)
      result = fetch_oembed(endpoint_template % URI.encode_www_form_component(url))
      return result if result.present?
    end
    fetch_html_og(url)
  end

  def fetch_oembed(endpoint)
    json = URI.open(endpoint, read_timeout: TIMEOUT, open_timeout: TIMEOUT).read
    data = JSON.parse(json)
    {
      title:       data["title"],
      description: data["author_name"],
      image:       data["thumbnail_url"],
      site_name:   data["provider_name"],
      domain:      URI.parse(endpoint).host&.sub(/\Awww\./, "")
    }.compact
  rescue => e
    Rails.logger.warn "oEmbed fetch error for #{endpoint}: #{e.message}"
    {}
  end

  def fetch_html_og(url)
    html = URI.open(
      url,
      "User-Agent"   => "Mozilla/5.0 (compatible; TeamVibesBot/1.0)",
      "Accept"       => "text/html",
      read_timeout:  TIMEOUT,
      open_timeout:  TIMEOUT
    ).read(500_000)

    doc = Nokogiri::HTML(html)

    {
      title:       og(doc, "og:title")       || doc.at_css("title")&.text&.strip,
      description: og(doc, "og:description") || meta_name(doc, "description"),
      image:       og(doc, "og:image"),
      site_name:   og(doc, "og:site_name"),
      domain:      URI.parse(url).host&.sub(/\Awww\./, "")
    }.compact
  end

  def og(doc, prop)
    doc.at_css("meta[property='#{prop}']")&.[]("content")&.strip&.presence
  end

  def meta_name(doc, name)
    doc.at_css("meta[name='#{name}']")&.[]("content")&.strip&.presence
  end
end
