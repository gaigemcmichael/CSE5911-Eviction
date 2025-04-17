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
      .where.not(UserID: @mediator&.UserID)
      .order(:ActiveMediations)
      .limit(3)
      .includes(:user)
  end

  def reassign
    @mediation = PrimaryMessageGroup.find(params[:id])
    new_mediator_id = params[:new_mediator_id]
    old_mediator_id = @mediation.MediatorID

    if new_mediator_id.blank?
      redirect_to admin_flagged_mediation_path(@mediation), alert: "No mediator selected." and return
    end

    if new_mediator_id.to_i == old_mediator_id
      redirect_to admin_flagged_mediation_path(@mediation), alert: "New mediator must be different from the current one." and return
    end

    ActiveRecord::Base.transaction do
      # Decrement old mediator
      if old_mediator_id
        old_mediator = Mediator.find_by(UserID: old_mediator_id)
        old_mediator.decrement!(:ActiveMediations) if old_mediator
      end

      # Assign new mediator
      @mediation.update!(MediatorID: new_mediator_id)

      # Increment new mediator
      new_mediator = Mediator.find_by(UserID: new_mediator_id)
      new_mediator.increment!(:ActiveMediations) if new_mediator

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
    end

    redirect_to admin_mediations_path, notice: "Mediator reassigned successfully. Parties will be prompted to complete new screening questions."
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
