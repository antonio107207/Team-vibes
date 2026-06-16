class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @conversations = current_user.conversations
      .includes(:sender, :recipient, messages: :sender)
      .order(updated_at: :desc)
  end

  def show
    @conversation = current_user.conversations.find(params[:id])
    @other_user   = @conversation.other_participant(current_user)
    @messages     = @conversation.messages.includes(:sender).order(:created_at)

    unread = @conversation.messages.where.not(sender: current_user).unread
    if unread.any?
      unread.update_all(read_at: Time.current)
      Turbo::StreamsChannel.broadcast_replace_to(
        "dm_badge:#{current_user.id}",
        target: "dm_count_badge",
        partial: "conversations/dm_badge",
        locals: { count: current_user.unread_dm_count }
      )
    end
  end

  def create
    other_user    = User.find(params[:recipient_id])
    @conversation = Conversation.between(current_user, other_user)
    redirect_to @conversation
  end
end
