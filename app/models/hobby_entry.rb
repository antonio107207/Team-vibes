class HobbyEntry < ApplicationRecord
  belongs_to :user
  has_many :likes,     as: :likeable,   dependent: :destroy
  has_many :comments,  as: :commentable, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :taggings,  dependent: :destroy
  has_many :tags,      through: :taggings
  has_many_attached :attachments

  attr_writer :tag_list

  after_save :persist_tag_list, if: -> { @tag_list }

  ALLOWED_TYPES = %w[
    image/jpeg image/png image/gif image/webp
    audio/mpeg audio/ogg audio/aac audio/flac audio/wav
    video/mp4 video/webm video/quicktime
  ].freeze
  MAX_SIZE = 50.megabytes

  validate :attachments_valid

  def attachment_type(attachment)
    ct = attachment.content_type
    return :image if ct.start_with?("image/")
    return :audio if ct.start_with?("audio/")
    return :video if ct.start_with?("video/")
    :other
  end

  enum :category, {
    movies: 0, music: 1, games: 2, pets: 3,
    books: 4, sports: 5, travel: 6, food: 7, other: 8
  }

  CATEGORY_ICONS = {
    "movies" => "🎬", "music" => "🎵", "games" => "🎮",
    "pets" => "🐾", "books" => "📚", "sports" => "⚽",
    "travel" => "✈️", "food" => "🍕", "other" => "⭐"
  }.freeze

  validates :title, presence: true
  validates :category, presence: true
  validates :rating, numericality: { in: 1..5 }, allow_nil: true

  def tag_list
    tags.loaded? ? tags.map(&:name).join(", ") : tags.pluck(:name).join(", ")
  end

  scope :recent,  -> { order(created_at: :desc) }
  scope :search,  ->(q) {
    p = "%#{sanitize_sql_like(q)}%"
    where("title ILIKE :p OR description ILIKE :p", p: p)
  }

  after_create_commit  -> { broadcast_refresh_to "feed" }
  after_destroy_commit -> { broadcast_refresh_to "feed" }

  def liked_by?(user)
    likes.exists?(user: user)
  end

  def favorited_by?(user)
    favorites.exists?(user: user)
  end

  def category_icon
    CATEGORY_ICONS[category] || "⭐"
  end

  private

  def persist_tag_list
    names = @tag_list.to_s.split(",")
                     .map { |n| n.strip.downcase.gsub(/\A#/, "").gsub(/\s+/, "-") }
                     .select(&:present?).uniq.first(10)
    self.tags = names.map { |name| Tag.find_or_create_by!(name: name) }
    @tag_list = nil
  end

  def attachments_valid
    attachments.each do |file|
      unless ALLOWED_TYPES.include?(file.content_type)
        errors.add(:attachments, "#{file.filename}: недозволений тип файлу")
      end
      if file.byte_size > MAX_SIZE
        errors.add(:attachments, "#{file.filename}: файл більше 50 МБ")
      end
    end
  end
end
