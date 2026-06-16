class TrendingController < ApplicationController
  WINDOW = 7.days

  def index
    @trending_entries = HobbyEntry
      .joins("LEFT JOIN likes ON likes.likeable_id = hobby_entries.id
              AND likes.likeable_type = 'HobbyEntry'
              AND likes.created_at >= '#{WINDOW.ago.iso8601}'")
      .where("hobby_entries.created_at >= ?", 30.days.ago)
      .includes(:user, :likes, :comments, :tags)
      .group("hobby_entries.id")
      .order("COUNT(likes.id) DESC, hobby_entries.created_at DESC")
      .page(params[:page]).per(10)

    @trending_tags = Tag
      .joins(taggings: :hobby_entry)
      .where(hobby_entries: { created_at: 30.days.ago.. })
      .group("tags.id")
      .order("COUNT(taggings.id) DESC")
      .limit(24)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
