class MessagesController < ApplicationController
  before_action :require_login
  before_action :set_user

  def index
    case @user.Role
    when "Tenant"
      @mediation = PrimaryMessageGroup.find_by(TenantID: @user.UserID)
      @show_mediation_view = @mediation.present?
      @landlords = User.where(Role: "Landlord").order(:CompanyName) unless @mediation
      render "messages/tenant_index"
    when "Landlord"
      @mediation = PrimaryMessageGroup.where(LandlordID: @user.UserID).includes(:tenant)
      @show_mediation_view = @mediation.any?
      render "messages/landlord_index"
    else
      render plain: "Access Denied", status: :forbidden
    end
  end

  def show

    @message_string = MessageString.find_by(ConversationID: params[:id])

    unless @message_string
      render plain: "Conversation not found", status: :not_found
      return
    end

    # this gets all the messages of the convo, need to decipher which ones are from who when displaying
    @messages = Message.where(ConversationID: @message_string.ConversationID).order(:MessageDate)

    case @user.Role
    when "Tenant"
      render "messages/tenant_show"
    when "Landlord"
      render "messages/landlord_show"
    else
      render plain: "Access Denied", status: :forbidden
    end
  end

  def create
    # Ensure the user is involved in the conversation
    conversation = MessageString.find_by(ConversationID: params[:ConversationID])
    
    if conversation
      # Create a new message
      @message = Message.create!(
        ConversationID: conversation.ConversationID,
        SenderID: @user.UserID,
        MessageDate: Time.current,
        Contents: params[:Contents]
      )

      if @message.save
        # Broadcast to ActionCable for both sender and receiver
        ActionCable.server.broadcast(
          "messages_#{conversation.ConversationID}",
          {
            message_id: @message.id,
            contents: @message.Contents,
            sender_id: @message.SenderID,
            message_date: @message.MessageDate.strftime("%B %d, %Y %I:%M %p"),
            sender_role: @user.Role
          }
        )
  
        # Prevent page reload and avoid "Conversation not found" error
        render status: :no_content, body: nil
      else
        # this needs better error handling, rn sends user to a dark screen with error message
        render plain: "There was an error saving your message.", status: :unprocessable_entity
      end
    else
      redirect_to messages_path, alert: "Conversation not found"
    end
  end

  private

  def require_login
    unless session[:user_id]
      redirect_to login_path, alert: "You must be logged in to access the dashboard."
    end
  end

  def set_user
    @user = User.find(session[:user_id])
  end
end
