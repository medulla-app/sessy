module Sessy
class MessagesController < ApplicationController
  include SourceScoped

  def show
    @message = @source.messages.includes(:events).find_by!(ses_message_id: params[:id])
  end
end
end
