class MentionsController < ApplicationController
  def index
    users = User.search(params[:q].to_s).order(:name).limit(6)
    render json: users.map { |u|
      { id: u.id, name: u.name, handle: u.name.gsub(/\s+/, "_"),
        avatar: avatar_url_for(u) }
    }
  end

  private

  def avatar_url_for(user)
    user.avatar.attached? ? url_for(user.avatar) : user.avatar_or_initials
  end
end
