class Notification < ApplicationRecord
  belongs_to :recipient,  class_name: "User"
  belongs_to :actor,      class_name: "User"
  belongs_to :notifiable, polymorphic: true, optional: true

  scope :unread,  -> { where(read_at: nil) }
  scope :recent,  -> { order(created_at: :desc) }

  after_create_commit :broadcast_notification

  def read?
    read_at.present?
  end

  private

  def broadcast_notification
    broadcast_prepend_to(
      "notifications:#{recipient_id}",
      target:  "notifications_list",
      partial: "notifications/notification",
      locals:  { notification: self }
    )
    broadcast_replace_to(
      "notifications:#{recipient_id}",
      target:  "notification_count_badge",
      partial: "notifications/count",
      locals:  { count: recipient.notifications.unread.count }
    )
  end
end
