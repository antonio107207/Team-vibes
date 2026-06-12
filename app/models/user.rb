class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :hobby_entries, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_entries, through: :favorites, source: :hobby_entry

  has_many :follows,         foreign_key: :follower_id, class_name: "Follow", dependent: :destroy
  has_many :followees,       through: :follows
  has_many :reverse_follows, foreign_key: :followee_id, class_name: "Follow", dependent: :destroy
  has_many :followers,       through: :reverse_follows, source: :follower

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
end
