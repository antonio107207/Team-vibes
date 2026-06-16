class TagsController < ApplicationController
  def show
    @tag     = Tag.find_by!(name: params[:name].to_s.downcase)
    @entries = @tag.hobby_entries
                   .includes(:user, :likes, :comments, :tags)
                   .order(created_at: :desc)
                   .page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t("tags.not_found")
  end
end
