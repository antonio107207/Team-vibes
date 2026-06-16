class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :hobby_entries, through: :taggings

  validates :name, presence: true, uniqueness: true,
                   length: { maximum: 32 },
                   format: { with: /\A[\w\-а-яіїєёА-ЯІЇЄЁ]+\z/i,
                              message: "only letters, digits, hyphens allowed" }

  before_validation { self.name = name.to_s.strip.downcase.gsub(/\s+/, "-") }
end
