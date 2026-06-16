class CommentsController < ApplicationController
  before_action :set_entry

  def create
    @comment = @entry.comments.build(comment_params.merge(user: current_user))
    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @entry }
      end
    else
      redirect_to @entry, alert: t("comments.empty_error")
    end
  end

  def destroy
    @comment = @entry.comments.find(params[:id])
    @comment.destroy if @comment.user == current_user
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @entry }
    end
  end

  private

  def set_entry
    @entry = HobbyEntry.find(params[:hobby_entry_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
