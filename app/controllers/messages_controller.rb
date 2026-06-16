class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def create
    @message = @conversation.messages.build(
      body:   message_params[:body],
      sender: current_user
    )
    if @message.save
      @conversation.touch
      respond_to do |f|
        f.turbo_stream
        f.html { redirect_to @conversation }
      end
    else
      redirect_to @conversation
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
