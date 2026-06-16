module ApplicationHelper
  def user_avatar_url(user)
    if user.avatar.attached?
      url_for(user.avatar)
    else
      user.avatar_or_initials
    end
  end

  def entry_locale(entry)
    text = strip_tags("#{entry.title} #{entry.description}")
    text.match?(/\p{Cyrillic}/) ? :uk : :en
  end

  def should_offer_translation?(entry)
    ENV["DEEPL_API_KEY"].present? && entry_locale(entry) != I18n.locale.to_sym
  end
end
