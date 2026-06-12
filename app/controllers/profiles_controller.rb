class ProfilesController < ApplicationController
  before_action :set_user

  def show
    @entries = @user.hobby_entries.includes(:likes, :comments).recent
    @entries_by_category = @entries.group_by(&:category)
  end

  def edit
    redirect_to root_path unless @user == current_user
  end

  def update
    redirect_to root_path unless @user == current_user
    if current_user.update(profile_params)
      redirect_to profile_path(current_user), notice: t('profiles.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def profile_params
    params.require(:user).permit(:name, :bio, :position, :avatar_url, :avatar)
  end
end
