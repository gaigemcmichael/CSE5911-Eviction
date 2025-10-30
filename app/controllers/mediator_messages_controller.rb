class MediatorMessagesController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_or_create_side_group

  def create
    @message = Message.new(
      ConversationID: @side_group.ConversationID,
      SenderID: @user.UserID,
      recipientID: @recipient_id,
      Contents: params[:Contents],
      MessageDate: Time.current
    )

    if @message.save
      if params[:file_id].present?
        file_draft = FileDraft.find_by(FileID: params[:file_id])

        if file_draft
          FileAttachment.create!(
            MessageID: @message.MessageID,
            FileID: file_draft.FileID
          )
        else
          Rails.logger.error "FileDraft not found with ID: #{params[:file_id]}"
        end
      end

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

      ActionCable.server.broadcast(
        "side_messages_#{@side_group.ConversationID}",
        {
          message_id: @message.id,
          contents: @message.Contents,
          sender_id: @message.SenderID,
          recipient_id: @message.recipientID,
          message_date: @message.MessageDate.strftime("%B %d, %Y %I:%M %p"),
          sender_role: @user.Role,
          sender_name: sender_name,
          attachments: attachments_payload
        }
      )

      respond_to do |format|
        format.json { render json: { success: true } }
        format.html { head :ok }
      end
    else
      respond_to do |format|
        format.json { render json: { error: @message.errors.full_messages }, status: :unprocessable_entity }
        format.html { head :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.find(session[:user_id])
  end

  def set_or_create_side_group
    @conversation_id = params[:conversation_id].to_i
    @recipient_id = params[:recipient_id].to_i

    # Ensure the mediator is one of the parties
    mediator_id = @user.Role == "Mediator" ? @user.UserID : @recipient_id
    user_id = @user.Role == "Mediator" ? @recipient_id : @user.UserID

    @side_group = SideMessageGroup.find_or_create_by!(
      UserID: user_id,
      MediatorID: mediator_id,
      ConversationID: @conversation_id
    )

    MessageString.find_or_create_by!(
      ConversationID: @conversation_id,
      Role: "Side"
    )
  end

  def require_login
    redirect_to login_path, alert: "Please log in to continue" unless session[:user_id]
  end
end
