class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :create, :destroy ]

  def index
    @followees = current_user.followees.includes(:hobby_entries).order(:name)
  end

  def create
    current_user.follows.find_or_create_by!(followee: @user) unless @user == current_user
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to profile_path(@user) }
    end
  end

  def destroy
    current_user.follows.find_by(followee: @user)&.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to profile_path(@user) }
    end
  end

  private

  def set_user
    @user = User.find(params[:profile_id])
  end
end
