class FeedController < ApplicationController
  def index
    scope = HobbyEntry.includes(:user, :likes, :comments)

    if params[:filter] == "following"
      scope = scope.where(user_id: current_user.followee_ids)
    end

    scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
    scope = scope.where(created_at: Date.parse(params[:from]).beginning_of_day..) if params[:from].present?
    scope = scope.where(created_at: ..Date.parse(params[:to]).end_of_day) if params[:to].present?

    order_dir = params[:sort] == "oldest" ? :asc : :desc
    @entries = scope.order(created_at: order_dir).page(params[:page]).per(10)
    @users = User.joins(:hobby_entries).distinct.order(:name)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  rescue ArgumentError
    @entries = HobbyEntry.none.page(1)
    @users = User.joins(:hobby_entries).distinct.order(:name)
  end
end
