class MessagesController < ApplicationController
  guard_feature unless: -> { Current.user.ai_enabled? }

  before_action :set_chat

  def create
    @message = UserMessage.new(
      chat: @chat,
      content: message_params[:content].to_s.presence || "",
      ai_model: message_params[:ai_model].presence || Chat.default_model
    )
    @message.image.attach(message_params[:image]) if message_params[:image].present?
    @message.save!

    redirect_to chat_path(@chat, thinking: true)
  end

  private
    def set_chat
      @chat = Current.user.chats.find(params[:chat_id])
    end

    def message_params
      params.require(:message).permit(:content, :ai_model, :image)
    end
end
