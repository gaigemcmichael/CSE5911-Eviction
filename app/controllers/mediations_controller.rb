class MediationsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :require_tenant_or_landlord_role, only: [:index, :create, :respond]
  

  def index
  end

 # Create a new mediation using the selected landlord
  def create
    unless @user.Role == "Tenant"
      redirect_to mediations_path, alert: "Only tenants can start a mediation." and return
    end

    #filling out landlord form
    landlord = nil
    if params[:landlord_id].present?
      landlord = User.find_by(UserID: params[:landlord_id])
    elsif params[:landlord_email].present?
      landlord = User.find_by(Email: params[:landlord_email])
    else
      flash.now[:alert] = "Please select a landlord from the list or enter a landlord's email."
      @landlords = User.where(Role: "Landlord").order(:CompanyName)
      render :index and return
    end

    #make sure they fill in a proper land lord (probably unnecesary?)
    unless landlord && landlord.Role == "Landlord"
      flash.now[:alert] = "Invalid landlord selected."
      @landlords = User.where(Role: "Landlord").order(:CompanyName)
      render :index and return
    end

    #update DB
    ActiveRecord::Base.transaction do
      # Create a new conversation
      message_string = MessageString.create!(Role: 'Primary')
      Rails.logger.debug "Created MessageString: #{message_string.inspect}"

      conversation_id = message_string.ConversationID
      Rails.logger.debug "Extracted ConversationID: #{conversation_id.inspect}"


      # Create the mediation record linking tenant and landlord, maybe these flags should be nil not false?
      mediation = PrimaryMessageGroup.create!(
        ConversationID: conversation_id,
        TenantID: @user.UserID,
        LandlordID: landlord.UserID,
        CreatedAt: Time.current,
        GoodFaith: false,
        MediatorRequested: false,
        MediatorAssigned: false,
        EndOfConversationGoodFaithLandlord: false,
        EndOfConversationGoodFaithTenant: false
      )

      #I dont think this works yet, but I want to fix the recognition of active mediations first before working more on this portion (since it is currently very hard/impossible to test without that)
      Rails.logger.debug "Created Mediation: #{mediation.inspect}"

      redirect_to mediation_path(mediation), notice: "Mediation started with #{landlord.CompanyName}."
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

  def set_user
    @user = User.find(session[:user_id])
  end

  def require_login
    unless session[:user_id]
      redirect_to login_path, alert: "You must be logged in to access the mediations."
    end
  end

  def require_tenant_or_landlord_role
    unless ["Tenant", "Landlord"].include?(@user.Role)
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end
end
