class MediatorMessagesChannel < ApplicationCable::Channel
    def subscribed
      stream_from "side_messages_#{params[:conversation_id]}"
    end

    def unsubscribed
      # Cleanup
    end
  end
  