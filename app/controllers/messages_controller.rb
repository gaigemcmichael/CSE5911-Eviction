class MessagesController < ApplicationController
  before_action :require_login
  before_action :set_user

  def index
    case @user.Role
    when "Tenant"
      @mediation = PrimaryMessageGroup
                     .includes(:landlord)
                     .find_by(TenantID: @user.UserID, deleted_at: nil)

      @past_mediations = PrimaryMessageGroup
                           .includes(:landlord)
                           .where(TenantID: @user.UserID)
                           .where.not(deleted_at: nil)
                           .order(deleted_at: :desc)

      @show_mediation_view = @mediation.present?
      @landlords = User.where(Role: "Landlord").order(:CompanyName) unless @mediation

      render "messages/tenant_index"

    when "Landlord"
      @mediation = PrimaryMessageGroup
                     .includes(:tenant)
                     .where(LandlordID: @user.UserID, deleted_at: nil)

      @past_mediations = PrimaryMessageGroup
                           .includes(:tenant)
                           .where(LandlordID: @user.UserID)
                           .where.not(deleted_at: nil)
                           .order(deleted_at: :desc)

      @show_mediation_view = @mediation.any?

      render "messages/landlord_index"

    else
      render plain: "Access Denied", status: :forbidden
    end
  end

  def show
    @message_string = MessageString.find_by(ConversationID: params[:id])
    @mediation = PrimaryMessageGroup.find_by(ConversationID: params[:id])

    # Edge Case error handling
    if @mediation.nil? || @message_string.nil?
      render plain: "Conversation not found", status: :not_found
      return
    end
  
    if @mediation.deleted_at.present? || @message_string.deleted_at.present?
      redirect_to mediation_ended_prompt_path(@mediation.ConversationID)
      return
    end

    # Load mediatior chat recipient
    if @mediation&.MediatorAssigned
      @mediator = User.find_by(UserID: @mediation.MediatorID)

      if @user.Role == "Tenant"
        @recipient = @mediator
      elsif @user.Role == "Landlord"
        @recipient = @mediator
      elsif @user.Role == "Mediator"
        # Optional: if the mediator is viewing the case, this helps find the tenant or landlord
        tenant = User.find_by(UserID: @mediation.TenantID)
        landlord = User.find_by(UserID: @mediation.LandlordID)
        @tenant_recipient = tenant
        @landlord_recipient = landlord
      end
    end

    unless @message_string
      render plain: "Conversation not found", status: :not_found
      return
    end

    @messages = Message.where(ConversationID: @message_string.ConversationID).order(:MessageDate)

    mediator_chat_ready = @mediation&.MediatorRequested && @mediation&.MediatorAssigned &&
      ((@user.Role == "Tenant" && @mediation.TenantScreeningID.present?) ||
      (@user.Role == "Landlord" && @mediation.LandlordScreeningID.present?))

    if mediator_chat_ready
      # Load mediator <-> current user side conversation
      side_group = SideMessageGroup.find_by(
        UserID: @user.UserID,
        MediatorID: @mediation.MediatorID
      )

      if side_group
        @message_string = MessageString.find_by(ConversationID: side_group.ConversationID)
        @messages = Message.where(ConversationID: @message_string.ConversationID).order(:MessageDate)
        @mediator = User.find_by(UserID: @mediation.MediatorID)
      end
    end

    render "messages/show"
  end

  def request_mediator
    @mediation = PrimaryMessageGroup.find(params[:id]) # Ensure we find the right mediation record

    # Edge case error handling
    if @mediation.deleted_at.present?
      redirect_to mediation_ended_prompt_path(@mediation.ConversationID)
      return
    end

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

        # Create SideMessageGroup for mediatior chatboxes
        side_convo_tenant = MessageString.create!(Role: "Side")
        side_convo_landlord = MessageString.create!(Role: "Side")

        # Create SideMessageGroup entries for tenant and landlord
        SideMessageGroup.find_or_create_by!(
          UserID: @mediation.TenantID,
          MediatorID: mediator.UserID,
          ConversationID: side_convo_tenant.ConversationID
        )

        SideMessageGroup.find_or_create_by!(
          UserID: @mediation.LandlordID,
          MediatorID: mediator.UserID,
          ConversationID: side_convo_landlord.ConversationID
        )

        # Hide the chatbox for other party upon mediator request
        ActionCable.server.broadcast(
          "messages_#{@mediation.ConversationID}",
          {
            type: "mediator_assigned"
          }
        )
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

      # Handle file attachment if present
      if params[:file_id].present?
        # Find the selected FileDraft by FileID
        file_draft = FileDraft.find_by(FileID: params[:file_id])

       # Create a file attachment
       if file_draft
          FileAttachment.create!(
            MessageID: @message.MessageID,
            FileID: file_draft.FileID
          )
       else
          Rails.logger.error "FileDraft not found with ID: #{params[:file_id]}"
       end
      end

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

        respond_to do |format|
          format.html { redirect_to message_path(conversation.ConversationID) }
          format.json { render json: { success: true, message_id: @message.id }, status: :created }
        end
      else
        respond_to do |format|
          format.html { redirect_to message_path(conversation.ConversationID), alert: "Failed to send message." }
          format.json { render json: { error: @message.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to messages_path, alert: "Conversation not found" }
        format.json { render json: { error: "Conversation not found" }, status: :not_found }
      end
    end
  end

  # Allows a user to view summaries of previous mediations
  def summary
    @mediation = PrimaryMessageGroup.find_by(ConversationID: params[:id])

    if @mediation.nil? || @mediation.deleted_at.nil?
      redirect_to messages_path, alert: "Mediation not found or still active."
      return
    end

    @tenant = User.find_by(UserID: @mediation.TenantID)
    @landlord = User.find_by(UserID: @mediation.LandlordID)

    render "messages/summary"
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
end
