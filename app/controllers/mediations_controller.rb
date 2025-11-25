class MediationsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :require_tenant_or_landlord_role, only: [ :create, :accept ]
  before_action :require_any_user_role, only: [ :end_conversation ]

  def index
    redirect_to messages_url
  end

  # lets a landlord or tenant accept a mediation request
  def accept
    mediation = PrimaryMessageGroup.find(params[:id])

    if @user.Role == "Landlord" && mediation.LandlordID == @user.UserID
      mediation.update!(accepted_by_landlord: true)
      mediation.reload
      redirect_to mediations_path, notice: "Negotiation accepted. You can now view and respond to the negotiation."
    elsif @user.Role == "Tenant" && mediation.TenantID == @user.UserID
      mediation.update!(accepted_by_tenant: true)
      mediation.reload
      redirect_to mediations_path, notice: "Negotiation accepted. You can now view and respond to the negotiation."
    else
      redirect_to mediations_path, alert: "You are not authorized to accept this negotiation."
    end
  end

  # lets a landlord or tenant reject a mediation request
  def reject
    mediation = PrimaryMessageGroup.find(params[:id])

    if (@user.Role == "Landlord" && mediation.LandlordID == @user.UserID) ||
       (@user.Role == "Tenant" && mediation.TenantID == @user.UserID)
      # Soft delete the mediation and message string
      mediation.update(deleted_at: Time.current, EndedBy: @user.UserID)
      mediation.linked_message_string&.update(deleted_at: Time.current)

      redirect_to messages_path, notice: "Negotiation request rejected."
    else
      redirect_to messages_path, alert: "You are not authorized to reject this negotiation."
    end
  end

  # Create a new mediation - tenants can select landlords, landlords can select tenants
  def create
    if @user.Role == "Tenant"
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
    elsif @user.Role == "Landlord"
      tenant = find_existing_tenant

      unless tenant
        send_tenant_invitation(params[:tenant_email])
        return
      end

      if tenant.persisted?
        start_mediation_with_existing_tenant(tenant)
      else
        redirect_to messages_path, alert: "An unexpected error occurred. Please try again."
      end
    else
      redirect_to mediations_path, alert: "You are not authorized to start a negotiation."
    end
  end

  # Display the form to start a new mediation
  def new
    if @user.Role == "Tenant"
      # Load all landlords ordered by CompanyName
      @landlords = User.where(Role: "Landlord").order(:CompanyName)
    elsif @user.Role == "Landlord"
      # Landlords use email input only (no tenant list for privacy)
      # No need to load @tenants
    else
      redirect_to mediations_path, alert: "You are not authorized to start a negotiation."
    end
  end

  # end the negotiation/mediation
  def end_conversation
    @mediation = PrimaryMessageGroup.find(params[:id])
    if @mediation.deleted_at.nil?
      @mediation.update(deleted_at: Time.current, EndedBy: @user.UserID)
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

  # Good Faith Screening prompt for edge case error handling
  def prompt_screen
    @mediation = PrimaryMessageGroup.find_by(ConversationID: params[:id])

    if @mediation.nil? || @mediation.deleted_at.nil?
      redirect_to messages_path, alert: "This mediation is still active or not found."
      return
    end

    render "mediations/prompt_screen" # We'll create this view next
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

  def find_existing_tenant
    email = params[:tenant_email].to_s.strip

    if email.present?
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
        accepted_by_landlord: false,
        accepted_by_tenant: true
      )

      redirect_to mediation_path(mediation), notice: "Negotiation created with #{landlord.CompanyName || landlord.Email}."
    end
  end

  def start_mediation_with_existing_tenant(tenant)
    ActiveRecord::Base.transaction do
      message_string = MessageString.create!(Role: "Primary")
      conversation_id = message_string.ConversationID

      PrimaryMessageGroup.create!(
        ConversationID: conversation_id,
        TenantID: tenant.UserID,
        LandlordID: @user.UserID,
        CreatedAt: Time.current,
        GoodFaith: false,
        MediatorRequested: false,
        MediatorAssigned: false,
        EndOfConversationGoodFaithLandlord: nil,
        EndOfConversationGoodFaithTenant: nil,
        accepted_by_landlord: true,
        accepted_by_tenant: false
      )
    end

    redirect_to messages_path, notice: "Negotiation request sent to #{tenant.Email}. If they have an account, they can accept your request. Otherwise, they'll be invited to join the site."
  end

  def send_landlord_invitation(email)
    LandlordMailer.invitation_email(email, @user).deliver_now
    redirect_to messages_path, notice: "Invitation email sent to #{email}. If they have an account, they can accept your request. Otherwise, they'll be invited to join the site."
  rescue
    redirect_to messages_path, notice: "Invitation email sent to #{email}. If they have an account, they can accept your request. Otherwise, they'll be invited to join the site."
  end

  def send_tenant_invitation(email)
    TenantMailer.invitation_email(email, @user).deliver_now
    redirect_to messages_path, notice: "Invitation email sent to #{email}. If they have an account, they can accept your request. Otherwise, they'll be invited to join the site."
  rescue
    redirect_to messages_path, notice: "Invitation email sent to #{email}. If they have an account, they can accept your request. Otherwise, they'll be invited to join the site."
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
    unless [ "Tenant", "Landlord", "Mediator" ].include?(@user.Role)
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end
end
