class LikesController < ApplicationController
  before_action :set_entry

  def create
    @entry.likes.find_or_create_by(user: current_user)
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
