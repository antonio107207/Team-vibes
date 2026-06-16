class Conversation < ApplicationRecord
  belongs_to :sender,    class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many   :messages,  dependent: :destroy

  validates :sender_id, uniqueness: { scope: :recipient_id }

  def self.between(user_a, user_b)
    a_id, b_id = [ user_a.id, user_b.id ].sort
    find_or_create_by!(sender_id: a_id, recipient_id: b_id)
  end

  def other_participant(user)
    user.id == sender_id ? recipient : sender
  end

  def unread_count_for(user)
    messages.where.not(sender: user).where(read_at: nil).count
  end
end
