module ApplicationHelper
  MENTION_RE = /@([\p{Word}]+)/

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
    ENV["DEEPL_API_KEY"].present? &&
      entry.user_id != current_user&.id &&
      entry_locale(entry) != I18n.locale.to_sym
  end

  def notification_text(notification)
    actor_name = notification.actor.name
    title      = notification.notifiable&.title.to_s.truncate(40)
    case notification.action
    when "liked"      then t("notifications.liked",      actor: actor_name, title: title)
    when "commented"  then t("notifications.commented",  actor: actor_name, title: title)
    when "followed"   then t("notifications.followed",   actor: actor_name)
    when "mentioned"  then t("notifications.mentioned",  actor: actor_name, title: title)
    else actor_name
    end
  end

  def render_mention_body(body)
    html = h(body).gsub(MENTION_RE) do |match|
      handle = Regexp.last_match(1)
      name   = handle.gsub("_", " ")
      user   = User.find_by("lower(name) = lower(?)", name)
      if user
        link_to("@#{handle}", profile_path(user),
                class: "text-indigo-600 dark:text-indigo-400 hover:underline font-medium")
      else
        match
      end
    end
    html.html_safe
  end

  def notification_link(notification)
    case notification.action
    when "liked", "commented"
      notification.notifiable ? hobby_entry_path(notification.notifiable) : root_path
    when "followed"
      profile_path(notification.actor)
    when "mentioned"
      notification.notifiable ? hobby_entry_path(notification.notifiable) : root_path
    else
      root_path
    end
  end
end
