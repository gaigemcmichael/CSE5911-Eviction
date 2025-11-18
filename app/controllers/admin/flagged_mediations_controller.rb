class Admin::FlaggedMediationsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :authorize_admin # Ensures Only Admins Can deal with flagged mediations

  def index
    @flagged_mediations = PrimaryMessageGroup
      .includes(:tenant, :landlord, :mediator)
      .where.not(TenantScreeningID: nil)
      .or(PrimaryMessageGroup.where.not(LandlordScreeningID: nil))
      .select do |pmg|
        tenant_flagged = pmg.TenantScreeningID && ScreeningQuestion.find_by(ScreeningID: pmg.TenantScreeningID)&.flagged
        landlord_flagged = pmg.LandlordScreeningID && ScreeningQuestion.find_by(ScreeningID: pmg.LandlordScreeningID)&.flagged
        tenant_flagged || landlord_flagged
      end

    @unassigned_mediations = PrimaryMessageGroup
      .where(MediatorRequested: true, MediatorAssigned: false)
      .includes(:tenant, :landlord)
  end

  def show
    @mediation = PrimaryMessageGroup.find(params[:id])
    @tenant = @mediation.tenant
    @landlord = @mediation.landlord
    @mediator = @mediation.mediator
    @tenant_screening = ScreeningQuestion.find_by(ScreeningID: @mediation.TenantScreeningID, deleted_at: nil)
    @landlord_screening = ScreeningQuestion.find_by(ScreeningID: @mediation.LandlordScreeningID, deleted_at: nil)

    @eligible_mediators = Mediator
      .where(Available: true)
      .where("ActiveMediations < MediationCap")
      .where.not(UserID: @mediator&.UserID) # Exclude current mediator if exists
      .order(:ActiveMediations)
      .limit(10)
      .includes(:user)
  end

  def reassign
    @mediation = PrimaryMessageGroup.find(params[:id])
    new_mediator_id = params[:new_mediator_id]
    old_mediator_id = @mediation.MediatorID

    if new_mediator_id.blank?
      redirect_to admin_flagged_mediation_path(@mediation), alert: "No mediator selected." and return
    end

    if old_mediator_id && new_mediator_id.to_i == old_mediator_id
      redirect_to admin_flagged_mediation_path(@mediation), alert: "New mediator must be different from the current one." and return
    end

    redirect_path = nil
    notice_msg = nil

    ActiveRecord::Base.transaction do
      # Decrement old mediator
      if old_mediator_id
        old_mediator = Mediator.find_by(UserID: old_mediator_id)
        old_mediator.decrement!(:ActiveMediations) if old_mediator
      end

      # Assign new mediator
      @mediation.update!(MediatorID: new_mediator_id, MediatorAssigned: true)

      # Increment new mediator
      new_mediator = Mediator.find_by(UserID: new_mediator_id)
      new_mediator.increment!(:ActiveMediations) if new_mediator

      if old_mediator_id
        # Reassignment Logic (Flagged Case)
        # Soft delete current screenings so users are required to submit new ones
        ScreeningQuestion.find_by(ScreeningID: @mediation.TenantScreeningID)&.soft_delete!
        ScreeningQuestion.find_by(ScreeningID: @mediation.LandlordScreeningID)&.soft_delete!

        # Clear associations so users are prompted to fill again
        @mediation.update!(TenantScreeningID: nil, LandlordScreeningID: nil)

        # Make the new message strings -> make the new side groups -> update the primaryg group FKs
        side_convo_tenant = MessageString.create!(Role: "Side")
        side_convo_landlord = MessageString.create!(Role: "Side")

        SideMessageGroup.create!(
          UserID: @mediation.TenantID,
          MediatorID: new_mediator_id,
          ConversationID: side_convo_tenant.ConversationID
        )

        SideMessageGroup.create!(
          UserID: @mediation.LandlordID,
          MediatorID: new_mediator_id,
          ConversationID: side_convo_landlord.ConversationID
        )

        @mediation.update!(
          TenantSideConversationID: side_convo_tenant.ConversationID,
          LandlordSideConversationID: side_convo_landlord.ConversationID
        )

        redirect_path = admin_mediations_path
        notice_msg = "Mediator reassigned successfully. Parties will be prompted to complete new screening questions."
      else
        # Initial Assignment Logic
        # Create SideMessageGroup for mediatior chatboxes
        side_convo_tenant = MessageString.create!(Role: "Side")
        side_convo_landlord = MessageString.create!(Role: "Side")

        # Create SideMessageGroup entries for tenant and landlord
        SideMessageGroup.find_or_create_by!(
          UserID: @mediation.TenantID,
          MediatorID: new_mediator_id,
          ConversationID: side_convo_tenant.ConversationID
        )

        SideMessageGroup.find_or_create_by!(
          UserID: @mediation.LandlordID,
          MediatorID: new_mediator_id,
          ConversationID: side_convo_landlord.ConversationID
        )

        # Update PrimaryMessageGroup with new side conversation IDs
        @mediation.update!(
          TenantSideConversationID: side_convo_tenant.ConversationID,
          LandlordSideConversationID: side_convo_landlord.ConversationID
        )

        # Broadcast mediator assigned
        mediator_user = User.find(new_mediator_id)
        mediator_name = "#{mediator_user.FName} #{mediator_user.LName}"

        ActionCable.server.broadcast(
          "messages_#{@mediation.ConversationID}",
          {
            type: "mediator_assigned",
            mediator_name: mediator_name
          }
        )

        # Create system message "Mediator (Name) has been assigned..."
        content = "Mediator #{mediator_name} has been assigned to this mediation."

        message = Message.create!(
          ConversationID: @mediation.ConversationID,
          SenderID: new_mediator_id,
          MessageDate: Time.current,
          Contents: content,
          recipientID: nil # Broadcast to all
        )

        ActionCable.server.broadcast(
          "messages_#{@mediation.ConversationID}",
          {
            message_id: message.id,
            contents: message.Contents,
            sender_id: message.SenderID,
            recipient_id: nil,
            message_date: message.MessageDate.strftime("%B %d, %Y %I:%M %p"),
            sender_role: "Mediator",
            sender_name: "#{mediator_user.FName} #{mediator_user.LName}",
            attachments: [],
            broadcast: true
          }
        )

        redirect_path = admin_mediations_path
        notice_msg = "Mediator assigned successfully."
      end
    end

    redirect_to redirect_path || admin_mediations_path, notice: notice_msg || "Operation successful."
  end

  def unflag
    @mediation = PrimaryMessageGroup.find(params[:id])
    tenant_screening = ScreeningQuestion.find_by(ScreeningID: @mediation.TenantScreeningID, deleted_at: nil)
    landlord_screening = ScreeningQuestion.find_by(ScreeningID: @mediation.LandlordScreeningID, deleted_at: nil)

    tenant_screening&.update!(flagged: false) if tenant_screening&.active?
    landlord_screening&.update!(flagged: false) if landlord_screening&.active?

    redirect_to admin_mediations_path, notice: "Mediation unflagged. Current screening responses will remain."
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

  def authorize_admin
    unless @user.Role == "Admin"
      redirect_to dashboard_path, alert: "Access Denied"
    end
  end
end
