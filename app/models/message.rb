class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  validates :body, presence: true, length: { maximum: 1000 }

  scope :unread, -> { where(read_at: nil) }

  after_create_commit :broadcast_new_message

  private

  def broadcast_new_message
    [ conversation.sender, conversation.recipient ].each do |user|
      broadcast_append_to(
        "conversation_#{conversation_id}:#{user.id}",
        target: "messages_list",
        partial: "messages/message",
        locals: { message: self, viewer_id: user.id }
      )
      broadcast_replace_to(
        "conversations_list:#{user.id}",
        target: "conversation_#{conversation_id}_preview",
        partial: "conversations/preview",
        locals: { conversation: conversation, current_user: user }
      )
    end

    recipient = conversation.sender_id == sender_id ? conversation.recipient : conversation.sender
    broadcast_replace_to(
      "dm_badge:#{recipient.id}",
      target: "dm_count_badge",
      partial: "conversations/dm_badge",
      locals: { count: recipient.unread_dm_count }
    )
  end
end
