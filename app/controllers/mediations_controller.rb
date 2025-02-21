class MediationsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :require_tenant_or_landlord_role, only: [ :create, :respond, :accept ]


  def accept
    mediation = PrimaryMessageGroup.find(params[:id])
    
    if @user.Role == "Landlord" && mediation.LandlordID == @user.UserID
      mediation.update!(accepted_by_landlord: true)
      mediation.reload
      redirect_to mediations_path, notice: "Mediation accepted. You can now view and respond to the mediation."
    else
      redirect_to mediations_path, alert: "You are not authorized to accept this mediation."
    end
  end

  # Create a new mediation using the selected landlord
  def create
    Rails.logger.debug "DEBUG: Entered MediationsController#create with params: #{params.inspect}"

    unless @user.Role == "Tenant"
      Rails.logger.error "ERROR: Non-tenant user attempted to create mediation"
      redirect_to mediations_path, alert: "Only tenants can start a mediation." and return
    end

    landlord = find_or_invite_landlord
    Rails.logger.debug "DEBUG: Found landlord - #{landlord.inspect}"

    unless landlord
      Rails.logger.error "ERROR: No landlord found or invitation sent"
      redirect_to mediations_path, alert: "Invalid landlord selected or email invitation sent." and return
    end

    if landlord.persisted?
      Rails.logger.debug "DEBUG: Starting mediation with existing landlord..."
      start_mediation_with_existing_landlord(landlord)
    else
      Rails.logger.debug "DEBUG: Sending landlord invitation email..."
      send_landlord_invitation(params[:landlord_email])
    end
  end

  # Display the form to start a new mediation (only tenants can start)
  def new
    if @user.Role != "Tenant"
      redirect_to mediations_path, alert: "Only tenants can start a mediation." and return
    end

    # Load all landlords ordered by CompanyName
    @landlords = User.where(Role: "Landlord").order(:CompanyName)
  end

  def respond
  end

  private

  def find_or_invite_landlord
    if params[:landlord_id].present? && params[:landlord_id] != ""
      User.find_by(UserID: params[:landlord_id])
    elsif params[:landlord_email].present?
      User.find_by(Email: params[:landlord_email]) || invite_new_landlord(params[:landlord_email])
    end
  end

  def invite_new_landlord(email)
    # Create a placeholder landlord record with limited permissions until signup is complete
    User.create!(Email: email, Role: "Landlord", invited: true)
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def start_mediation_with_existing_landlord(landlord)
    ActiveRecord::Base.transaction do
      message_string = MessageString.create!(Role: "Primary")
      conversation_id = message_string.ConversationID

      mediation = PrimaryMessageGroup.create!(
        ConversationID: conversation_id,
        TenantID: @user.UserID,
        LandlordID: landlord.UserID,
        CreatedAt: Time.current,
        GoodFaith: false,
        MediatorRequested: false,
        MediatorAssigned: false,
        EndOfConversationGoodFaithLandlord: false,
        EndOfConversationGoodFaithTenant: false,
        accepted_by_landlord: false
      )

      redirect_to mediation_path(mediation), notice: "Mediation created with #{landlord.CompanyName || landlord.Email}."
    end
  end

  def send_landlord_invitation(email)
    # TODO: Implement email sending functionality here
    # e.g., LandlordMailer.invitation_email(email).deliver_later

    redirect_to mediations_path, notice: "No landlord found with that email. An invitation was sent to #{email}."
  end

  def set_user
    @user = User.find(session[:user_id])
  end

  def require_login
    unless session[:user_id]
      redirect_to login_path, alert: "You must be logged in to access the mediations."
    end
  end

  def require_tenant_or_landlord_role
    unless [ "Tenant", "Landlord" ].include?(@user.Role)
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end
end
