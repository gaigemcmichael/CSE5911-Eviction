class MessagesController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_message, only: [ :request_mediator ]

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

    @mediation = PrimaryMessageGroup.find_by(ConversationID: params[:id])

    case @user.Role
    when "Tenant"
      render "messages/tenant_show"
    when "Landlord"
      render "messages/landlord_show"
    else
      render plain: "Access Denied", status: :forbidden
    end
  end

  def request_mediator
    @mediation = PrimaryMessageGroup.find(params[:id]) # Ensure we find the right mediation record

    if !@mediation.MediatorRequested && !@mediation.MediatorAssigned
      mediator = Mediator
        .where(Available: true)
        .where("ActiveMediations < MediationCap")
        .order("ActiveMediations ASC")
        .first

      if mediator
        # Assign the mediator to the mediation
        @mediation.update!(
          MediatorRequested: true,
          MediatorAssigned: true,
          MediatorID: mediator.UserID
        )
        mediator.increment!(:ActiveMediations)
        # not sure on these redirects, they seem to work but also kinda hard to test obv
        redirect_back fallback_location: messages_path, notice: "Mediator requested successfully."
      else
        redirect_back fallback_location: messages_path, alert: "No available mediators at this time. Please try again later."
      end
    else
      redirect_back fallback_location: messages_path, alert: "Failed to request a mediator."
    end
  end


  def create
    # Ensure the user is involved in the conversation
    conversation = MessageString.find_by(ConversationID: params[:ConversationID])

    if conversation
      # Determine Recipient
      recipient_id = determine_recipient(conversation)

      duplicate_exists = Message.where(
        SenderID: @user.UserID,
        ConversationID: params[:ConversationID],
        Contents: params[:Contents]
      ).where("MessageDate >= ?", 2.seconds.ago).exists?
    
      if duplicate_exists
        Rails.logger.info "Duplicate message detected, blocking it."
        return render status: :no_content, body: nil
      end

      # Create a new message
      @message = Message.create!(
        ConversationID: conversation.ConversationID,
        SenderID: @user.UserID,
        recipientID: recipient_id,
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
            recipient_id: @message.recipientID,
            message_date: @message.MessageDate.strftime("%B %d, %Y %I:%M %p"),
            sender_role: @user.Role
          }
        )

        # Prevent page reload and avoid "Conversation not found" error
        render json: { success: true, message_id: @message.id }, status: :created
      else
        Rails.logger.error "Message save failed: #{@message.errors.full_messages}"
        render json: { error: @message.errors.full_messages }, status: :unprocessable_entity
      end
    else
      redirect_to messages_path, alert: "Conversation not found"
    end
  end

  private

  def determine_recipient(conversation)
    primary_group = PrimaryMessageGroup.find_by(ConversationID: conversation.ConversationID)

    if primary_group.nil?
      raise "There was an issue finding the mediation group for this conversation."
    end

    if @user.Role == "Tenant"
      primary_group.LandlordID
    elsif @user.Role == "Landlord"
      primary_group.TenantID
    else
      nil # Handle unexpected roles
    end
  end

  def require_login
    unless session[:user_id]
      redirect_to login_path, alert: "You must be logged in to access the dashboard."
    end
  end

  def set_user
    @user = User.find(session[:user_id])
  end

  def set_message
    @message = Message.find(params[:id])
  end
end
