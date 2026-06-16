class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true, length: { maximum: 500 }

  after_create_commit :create_notification
  after_create_commit :notify_mentions

  private

  def create_notification
    return unless commentable_type == "HobbyEntry"
    return if user_id == commentable.user_id
    Notification.create!(recipient: commentable.user, actor: user, notifiable: commentable, action: "commented")
  end

  MENTION_PATTERN = /@([\p{Word}]+)/

  def notify_mentions
    return unless commentable_type == "HobbyEntry"
    body.scan(MENTION_PATTERN).flatten.uniq.each do |handle|
      name    = handle.gsub("_", " ")
      mention = User.find_by("lower(name) = lower(?)", name)
      next unless mention
      next if mention.id == user_id
      next if mention.id == commentable.user_id
      Notification.create!(recipient: mention, actor: user, notifiable: commentable, action: "mentioned")
    end
  end
end
