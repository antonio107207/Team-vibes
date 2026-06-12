class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :hobby_entry

  validates :user_id, uniqueness: { scope: :hobby_entry_id }
end
