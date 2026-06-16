class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :hobby_entry

  validates :tag_id, uniqueness: { scope: :hobby_entry_id }
end
