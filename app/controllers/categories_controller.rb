class CategoriesController < ApplicationController
  def show
    category = params[:category]
    unless HobbyEntry.categories.key?(category)
      redirect_to root_path, alert: t('categories.not_found')
      return
    end
    @category = category
    @entries = HobbyEntry.where(category: category)
                         .includes(:user, :likes, :comments)
                         .recent
                         .page(params[:page]).per(20)
  end
end
