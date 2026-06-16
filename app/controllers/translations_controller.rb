class TranslationsController < ApplicationController
  before_action :ensure_deepl_configured

  def create
    target_lang = I18n.locale == :uk ? "UK" : "EN"
    title       = params[:title].presence
    description = params[:description].presence

    render json: {
      title: title ? cached_translate(title, target_lang, html: false) : nil,
      description: description ? cached_translate(description, target_lang, html: true) : nil
    }
  rescue => e
    Rails.logger.error "Translation error: #{e.message}"
    render json: { error: "Translation failed" }, status: :unprocessable_entity
  end

  private

  def ensure_deepl_configured
    return if ENV["DEEPL_API_KEY"].present?
    render json: { error: "Translation not configured" }, status: :service_unavailable
  end

  def cached_translate(text, target_lang, html: false)
    cache_key = "deepl/#{target_lang}/#{html}/#{Digest::MD5.hexdigest(text)}"
    Rails.cache.fetch(cache_key, expires_in: 30.days) do
      opts = html ? { tag_handling: "html" } : {}
      translated = DeepL.translate(text, nil, target_lang, **opts).text
      html ? helpers.sanitize(translated) : translated
    end
  end
end
