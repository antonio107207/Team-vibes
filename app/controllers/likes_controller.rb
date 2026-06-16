class LikesController < ApplicationController
  before_action :set_entry

  def create
    emoji = params[:emoji].presence_in(Like::EMOJIS) || "❤️"
    existing = @entry.likes.find_by(user: current_user, emoji: emoji)
    if existing
      existing.destroy
    else
      @entry.likes.create!(user: current_user, emoji: emoji)
    end
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to @entry }
    end
  end

  def destroy
    @entry.likes.find_by(user: current_user)&.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to @entry }
    end
  end

  private

  def set_entry
    @entry = HobbyEntry.find(params[:hobby_entry_id])
  end
end
