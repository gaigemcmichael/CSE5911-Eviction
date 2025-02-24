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

    #this gets all the messages of the convo, need to decipher which ones are from who when displaying
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
      message = Message.create!(
        ConversationID: conversation.ConversationID,
        SenderID: @user.UserID,
        MessageDate: Time.current,
        Contents: params[:Contents]
      )

      if @user.Role == "Tenant"
        redirect_to tenant_show_path(conversation_id: conversation.ConversationID), notice: "Message sent successfully."
      elsif @user.Role == "Landlord"
        redirect_to landlord_show_path(conversation_id: conversation.ConversationID), notice: "Message sent successfully."
      else
        redirect_to messages_path, alert: "Your role is not authorized to send messages."
      end
    else
      redirect_to messages_path, alert: "There was an error sending your message."
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
