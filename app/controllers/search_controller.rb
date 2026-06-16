class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip

    if @query.length >= 2
      @users = User.search(@query).order(:name).limit(8)

      scope = HobbyEntry.search(@query).includes(:user, :likes, :comments, :tags)
      scope = scope.where(category: params[:category]) if valid_category?
      order_dir = params[:sort] == "oldest" ? :asc : :desc
      @entries = scope.order(created_at: order_dir).page(params[:page]).per(10)
    else
      @users   = []
      @entries = HobbyEntry.none.page(1)
    end
  end

  private

  def valid_category?
    params[:category].present? && HobbyEntry.categories.key?(params[:category])
  end
end
