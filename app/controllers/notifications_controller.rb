class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications
                                 .includes(:actor, :notifiable)
                                 .recent
                                 .page(params[:page]).per(30)

    unread = current_user.notifications.unread
    if unread.any?
      unread.update_all(read_at: Time.current)
      Turbo::StreamsChannel.broadcast_replace_to(
        "notifications:#{current_user.id}",
        target: "notification_count_badge",
        html:   ""
      )
    end
  end
end
