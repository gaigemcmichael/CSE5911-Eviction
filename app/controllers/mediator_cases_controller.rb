class MediatorCasesController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :authorize_mediator
  before_action :set_mediation, only: [ :show ]

  def show
    @mediation = PrimaryMessageGroup.find(params[:id])

    # Prevents edge case unauthorized access to a mediation that they are no longer assigned to
    if @mediation.MediatorID != @user.UserID
      redirect_to third_party_mediations_path, alert: "You are no longer assigned to this mediation."
      return
    end

    # Get tenant-side conversation
    tenant_side_group = SideMessageGroup.find_by(
      UserID: @mediation.TenantID,
      MediatorID: @mediation.MediatorID
    )
    tenant_msg_string = tenant_side_group && MessageString.find_by(ConversationID: tenant_side_group.ConversationID)

    # Get landlord-side conversation
    landlord_side_group = SideMessageGroup.find_by(
      UserID: @mediation.LandlordID,
      MediatorID: @mediation.MediatorID
    )
    landlord_msg_string = landlord_side_group && MessageString.find_by(ConversationID: landlord_side_group.ConversationID)

    @tenant_message_string = tenant_msg_string
    @landlord_message_string = landlord_msg_string

    @tenant_messages = tenant_msg_string ? Message.where(ConversationID: tenant_msg_string.ConversationID).order(:MessageDate) : []
    @landlord_messages = landlord_msg_string ? Message.where(ConversationID: landlord_msg_string.ConversationID).order(:MessageDate) : []
  end


  private

  def set_mediation
    @mediation = PrimaryMessageGroup.find(params[:id])
  end

  def require_login
    unless session[:user_id]
      redirect_to login_path, alert: "You must be logged in to access the dashboard."
    end
  end

  def set_user
    @user = User.find(session[:user_id])
  end

  def authorize_mediator
    unless @user.Role == "Mediator"
      redirect_to dashboard_path, alert: "Access Denied"
    end
  end
end
