class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :hobby_entries, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_entries, through: :favorites, source: :hobby_entry

  has_one_attached :avatar

  has_many :follows,              foreign_key: :follower_id, class_name: "Follow",       dependent: :destroy
  has_many :followees,            through: :follows
  has_many :reverse_follows,      foreign_key: :followee_id, class_name: "Follow",       dependent: :destroy
  has_many :followers,            through: :reverse_follows, source: :follower

  has_many :notifications,        foreign_key: :recipient_id, class_name: "Notification", dependent: :destroy
  has_many :sent_notifications,   foreign_key: :actor_id,     class_name: "Notification", dependent: :destroy

  has_many :sent_conversations,     foreign_key: :sender_id,    class_name: "Conversation", dependent: :destroy
  has_many :received_conversations, foreign_key: :recipient_id, class_name: "Conversation", dependent: :destroy

  scope :search, ->(q) { where("name ILIKE ?", "%#{sanitize_sql_like(q)}%") }

  validates :name, presence: true

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.avatar_url = auth.info.image
    end
  end

  def avatar_or_initials
    avatar_url.presence || "https://ui-avatars.com/api/?name=#{URI.encode_www_form_component(name)}&background=6366f1&color=fff"
  end

  def following?(user)
    follows.exists?(followee: user)
  end

  def conversations
    Conversation.where(sender_id: id).or(Conversation.where(recipient_id: id))
  end

  def unread_dm_count
    conv_ids = conversations.pluck(:id)
    return 0 if conv_ids.empty?
    Message.where(conversation_id: conv_ids).where.not(sender_id: id).unread.count
  end
end
