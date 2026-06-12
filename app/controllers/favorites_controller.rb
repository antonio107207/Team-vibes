class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entry, only: [:create, :destroy]

  def index
    @entries = current_user.favorited_entries
                           .includes(:user, :likes, :comments, :favorites)
                           .order("favorites.created_at DESC")
                           .page(params[:page]).per(20)
  end

  def create
    @entry.favorites.find_or_create_by!(user: current_user)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to @entry }
    end
  end

  def destroy
    @entry.favorites.find_by(user: current_user)&.destroy
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
