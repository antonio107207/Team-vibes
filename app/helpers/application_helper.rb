module ApplicationHelper
  def user_avatar_url(user)
    if user.avatar.attached?
      url_for(user.avatar)
    else
      user.avatar_or_initials
    end
  end
end
