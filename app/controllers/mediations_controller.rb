class MediationsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :require_tenant_or_landlord_role, only: [ :create, :respond, :accept ]

  def index
    redirect_to messages_path, alert: "Mediation index is not available. Please use the messages page."
  end

  # lets a landlord accept a mediation request
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

    unless @user.Role == "Tenant"
      redirect_to mediations_path, alert: "Only tenants can start a mediation." and return
    end

    landlord = find_existing_landlord

    unless landlord
      send_landlord_invitation(params[:landlord_email])
      return
    end

    if landlord.persisted?
      start_mediation_with_existing_landlord(landlord)
    else
      redirect_to messages_path, alert: "An unexpected error occurred. Please try again."
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

  def find_existing_landlord
    if params[:landlord_id].present? && params[:landlord_id] != ""
      User.find_by(UserID: params[:landlord_id])
    elsif params[:landlord_email].present?
      User.find_by(Email: params[:landlord_email])
    end
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
    begin
      LandlordMailer.invitation_email(email, @user).deliver_now
      flash[:notice] = "No landlord found with that email. An invitation was sent to #{email}. Please check back later to see if they have joined."
    rescue => e
      flash[:alert] = "An error occurred while sending the invitation to #{email}."
    end

    redirect_to messages_path
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
