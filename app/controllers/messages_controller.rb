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

      respond_to do |format|
        format.html { render "messages/tenant_index" }
      end

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

      respond_to do |format|
        format.html { render "messages/landlord_index" }
      end

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

    unless conversation_participant?(@mediation)
      render plain: "Access Denied", status: :forbidden
      return
    end

    if @user.Role == "Mediator" && @mediation.MediatorID != @user.UserID
      render plain: "Access Denied", status: :forbidden
      return
    end

    @mediator = @mediation.mediator if @mediation&.MediatorAssigned

    @messages = Message
      .where(ConversationID: @message_string.ConversationID)
      .includes(file_attachments: :file_draft)
      .order(:MessageDate)

    @broadcast_enabled = broadcast_conversation?(@mediation)

    participant_ids = [
      @user.UserID,
      @mediation.TenantID,
      @mediation.LandlordID,
      @mediation.MediatorID
    ].compact.uniq

    @conversation_participants = User.where(UserID: participant_ids).index_by(&:UserID)

    @message_placeholder = if @broadcast_enabled
      case @user.Role
      when "Mediator"
        "Message everyone in this mediation..."
      when "Tenant"
        "Message your landlord and mediator..."
      when "Landlord"
        "Message your tenant and mediator..."
      else
        "Type your message..."
      end
    else
      "Type your message..."
    end

    respond_to do |format|
      format.html { render "messages/show" }
    end
  end

  def request_mediator
    @mediation = PrimaryMessageGroup.find(params[:id]) # Ensure we find the right mediation record

    # Edge case error handling
    if @mediation.deleted_at.present?
      redirect_to mediation_ended_prompt_path(@mediation.ConversationID)
      return
    end

    if !@mediation.MediatorRequested && !@mediation.MediatorAssigned
      # Update to requested only
      @mediation.update!(MediatorRequested: true)

      # Create system message
      sender_name = [ @user.FName, @user.LName ].compact.join(" ")
      content = "#{sender_name} requested a mediator."

      # Create the message
      message = Message.create!(
        ConversationID: @mediation.ConversationID,
        SenderID: @user.UserID,
        MessageDate: Time.current,
        Contents: content,
        recipientID: determine_recipient(@mediation)
      )

      # Broadcast to ActionCable
      ActionCable.server.broadcast(
        "messages_#{@mediation.ConversationID}",
        {
          message_id: message.id,
          contents: message.Contents,
          sender_id: message.SenderID,
          recipient_id: message.recipientID,
          message_date: message.MessageDate.strftime("%B %d, %Y %I:%M %p"),
          sender_role: @user.Role,
          sender_name: sender_name,
          attachments: [],
          broadcast: false
        }
      )

      redirect_back fallback_location: messages_path, notice: "Mediator requested. An admin will assign one shortly."
    else
      redirect_back fallback_location: messages_path, alert: "Mediator already requested or assigned."
    end
  end


  def create
    # Ensure the user is involved in the conversation
    conversation = MessageString.find_by(ConversationID: params[:ConversationID])

    # Edge case error handling
    if conversation.deleted_at.present?
      redirect_to mediation_ended_prompt_path(conversation.ConversationID)
      return
    end

    if conversation
      primary_group = PrimaryMessageGroup.find_by(ConversationID: conversation.ConversationID)

      unless primary_group
        respond_to do |format|
          format.html { redirect_to messages_path, alert: "Conversation not found" }
          format.json { render json: { error: "Conversation not found" }, status: :not_found }
        end
        return
      end

      unless conversation_participant?(primary_group)
        respond_to do |format|
          format.html { redirect_to messages_path, alert: "Access denied" }
          format.json { render json: { error: "Access denied" }, status: :forbidden }
        end
        return
      end

      # Determine Recipient / broadcast behavior
      recipient_id = determine_recipient(primary_group)

      duplicate_exists = Message.where(
        SenderID: @user.UserID,
        ConversationID: params[:ConversationID],
        Contents: params[:Contents]
      ).where("MessageDate >= ?", 2.seconds.ago).exists?

      if duplicate_exists
        Rails.logger.info "Duplicate message detected, blocking it."
        respond_to do |format|
          format.html { head :no_content }
          format.json { render json: { duplicate: true }, status: :accepted }
        end
        return
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
        attachments_payload = @message
          .file_attachments
          .includes(:file_draft)
          .map do |attachment|
            file = attachment.file_draft
            next unless file

            extension = File.extname(file.FileURLPath.to_s).delete(".")
            {
              file_id: file.FileID,
              file_name: file.FileName,
              preview_url: view_file_path(file.FileID),
              download_url: download_file_path(file.FileID),
              view_url: view_file_path(file.FileID),
              sign_url: sign_document_path(file.FileID),
              tenant_signature_required: file.respond_to?(:TenantSignature) ? !file.TenantSignature : false,
              landlord_signature_required: file.respond_to?(:LandlordSignature) ? !file.LandlordSignature : false,
              extension: extension.presence || file.FileTypes
            }
          end
          .compact

        sender_name = [ @user.FName, @user.LName ].compact.join(" ").squeeze(" ").strip
        sender_name = @user.CompanyName.presence || @user.Email if sender_name.blank?

        # Broadcast to ActionCable for both sender and receiver
        ActionCable.server.broadcast(
          "messages_#{conversation.ConversationID}",
          {
            message_id: @message.id,
            contents: @message.Contents,
            sender_id: @message.SenderID,
            recipient_id: @message.recipientID,
            message_date: @message.MessageDate.strftime("%B %d, %Y %I:%M %p"),
            sender_role: @user.Role,
            sender_name: sender_name,
            attachments: attachments_payload,
            broadcast: recipient_id.nil?
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
    # Lookup both groups - side_mediation should be empty everytime, but not sure if changing that will mess up anything else (I didnt write it initially)
    @primary_mediation = PrimaryMessageGroup.find_by(ConversationID: params[:id])
    @side_mediation = SideMessageGroup.find_by(ConversationID: params[:id])

    # Make sure at least one exists and is closed (deleted_at present)
    if (@primary_mediation.nil? || @primary_mediation.deleted_at.nil?) &&
       (@side_mediation.nil? || @side_mediation.deleted_at.nil?)
      redirect_to messages_path, alert: "Mediation not found or still active."
      return
    end

    # For some code that already depends on this that I  didnt have time to refactor
    @mediation = @primary_mediation


    # Finding the tenant and landlord
    @tenant = User.find_by(UserID: @primary_mediation.TenantID)
    @landlord = User.find_by(UserID: @primary_mediation.LandlordID)

    # THis is going to be all of the conversation ids we need to check (reduces number of complicated queries needed)
    conversation_ids = []

    if @primary_mediation.present?
      # Add Primary id
      conversation_ids << @primary_mediation.ConversationID

      # Add Side Conversations from the Primary one, if they exist
      conversation_ids << @primary_mediation.TenantSideConversationID if @primary_mediation.TenantSideConversationID.present?
      conversation_ids << @primary_mediation.LandlordSideConversationID if @primary_mediation.LandlordSideConversationID.present?
    elsif @side_mediation.present?
      # If only a side was found directly, use it. This should never really happen but included just to be safe
      conversation_ids << @side_mediation.ConversationID
    end

    # Query to get the signed files, this could be simpler, but that would require some model changes that are going to be annoying too
    @signed_files = FileDraft
      .joins(file_attachments: :message)
      .where(
        messages: { ConversationID: [
          @mediation.ConversationID,
          @mediation.TenantSideConversationID,
          @mediation.LandlordSideConversationID
        ] }
      )
      .where(TenantSignature: true, LandlordSignature: true)
      .distinct
      .select("FileDrafts.*, Messages.ConversationID as ConversationID")


    render "messages/summary"
  end

  private

  def determine_recipient(primary_group)
    return nil unless primary_group

    if broadcast_conversation?(primary_group)
      nil
    else
      case @user.Role
      when "Tenant"
        primary_group.LandlordID
      when "Landlord"
        primary_group.TenantID
      when "Mediator"
        nil
      else
        nil
      end
    end
  end

  def broadcast_conversation?(primary_group)
    mediator_present = primary_group.MediatorRequested && primary_group.MediatorAssigned && primary_group.MediatorID.present?
    mediator_present
  end

  def conversation_participant?(primary_group)
    participant_ids = [
      primary_group.TenantID,
      primary_group.LandlordID,
      primary_group.MediatorID
    ].compact

    participant_ids.include?(@user.UserID)
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
