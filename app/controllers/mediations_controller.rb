class MediationsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :require_tenant_or_landlord_role, only: [ :create, :accept ]
  before_action :require_any_user_role, only: [:end_conversation]

  def index
    redirect_to messages_path, alert: "Negotiation index is not available. Please use the messages page."
  end

  # lets a landlord accept a mediation request
  def accept
    mediation = PrimaryMessageGroup.find(params[:id])

    if @user.Role == "Landlord" && mediation.LandlordID == @user.UserID
      mediation.update!(accepted_by_landlord: true)
      mediation.reload
      redirect_to mediations_path, notice: "Negotiation accepted. You can now view and respond to the negotiation."
    else
      redirect_to mediations_path, alert: "You are not authorized to accept this negotiation."
    end
  end

  # Create a new mediation using the selected landlord
  def create
    unless @user.Role == "Tenant"
      redirect_to mediations_path, alert: "Only tenants can start a negotiation." and return
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
      redirect_to mediations_path, alert: "Only tenants can start a negotiation." and return
    end

    # Load all landlords ordered by CompanyName
    @landlords = User.where(Role: "Landlord").order(:CompanyName)
  end

  # end the negotiation/mediation
  def end_conversation
    @mediation = PrimaryMessageGroup.find(params[:id])
    if @mediation.deleted_at.nil?
      @mediation.update(deleted_at: Time.current)
      @mediation.linked_message_string&.update(deleted_at: Time.current)

      # Decrement the mediator’s active mediation count if one is assigned
      if @mediation.MediatorID.present?
        mediator = Mediator.find_by(UserID: @mediation.MediatorID)
        if mediator && mediator.ActiveMediations > 0
          mediator.decrement!(:ActiveMediations)
        end
      end

    end
    if @user.Role == "Mediator"
      redirect_to third_party_mediations_path, notice: "Mediation terminated."
    else
      redirect_to good_faith_response_path(@mediation.ConversationID)
    end
  end

  # good faith questionaire
  def update_good_faith
    @mediation = PrimaryMessageGroup.find(params[:id])
    role = params[:role]
    good_faith = ActiveModel::Type::Boolean.new.cast(params[:good_faith])

    if role == "Tenant"
      @mediation.update!(EndOfConversationGoodFaithLandlord: good_faith)
    elsif role == "Landlord"
      @mediation.update!(EndOfConversationGoodFaithTenant: good_faith)
    end

    redirect_to messages_path
  end

  def good_faith_form
    @mediation = PrimaryMessageGroup.find_by(ConversationID: params[:id])
    if @mediation.nil? || @mediation.deleted_at.nil?
      redirect_to messages_path, alert: "Mediation not found or still ongoing."
      return
    end

    render "mediations/good_faith_feedback"
  end

  private

  def find_existing_landlord
    email = params[:landlord_email].to_s.strip

    if params[:landlord_id].present?
      User.find_by(UserID: params[:landlord_id])
    elsif email.present?
      User.find_by(Email: email)
    else
      nil
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
        EndOfConversationGoodFaithLandlord: nil,
        EndOfConversationGoodFaithTenant: nil,
        accepted_by_landlord: false
      )

      redirect_to mediation_path(mediation), notice: "Negotiation created with #{landlord.CompanyName || landlord.Email}."
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

  def require_any_user_role
    unless ["Tenant", "Landlord", "Mediator"].include?(@user.Role)
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end
end
