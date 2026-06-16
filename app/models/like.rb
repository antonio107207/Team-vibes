class Like < ApplicationRecord
  EMOJIS = %w[❤️ 🔥 👍 😂 😮 💡].freeze

  belongs_to :user
  belongs_to :likeable, polymorphic: true

  validates :emoji,    inclusion: { in: EMOJIS }
  validates :user_id,  uniqueness: { scope: [ :likeable_type, :likeable_id, :emoji ] }

  after_create_commit :create_notification

  private

  def create_notification
    return unless likeable_type == "HobbyEntry"
    return if user_id == likeable.user_id
    # One notification per user per entry regardless of emoji
    return if Notification.exists?(recipient: likeable.user, actor: user, notifiable: likeable, action: "liked")
    Notification.create!(recipient: likeable.user, actor: user, notifiable: likeable, action: "liked")
  end
end
