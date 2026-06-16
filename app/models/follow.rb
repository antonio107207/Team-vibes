class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followee, class_name: "User"

  validates :follower_id, uniqueness: { scope: :followee_id }
  validate :no_self_follow

  after_create_commit :create_notification

  private

  def no_self_follow
    errors.add(:base, "Cannot follow yourself") if follower_id == followee_id
  end

  def create_notification
    Notification.create!(recipient: followee, actor: follower, notifiable: nil, action: "followed")
  end
end
