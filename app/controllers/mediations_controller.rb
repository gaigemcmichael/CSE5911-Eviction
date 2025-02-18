class MediationsController < ApplicationController
  before_action :require_login
  before_action :require_tenant_or_landlord_role, only: [:index, :create, :respond]
  before_action :set_user

  def index
    if @user.Role == "Tenant"
      @mediation = PrimaryMessageGroups.find_by(TenantID: @user.UserID) # Find the single mediation the tenant is involved in.
    elsif @user.Role == "Landlord"
      @mediation = PrimaryMessageGroups.where(LandlordID: @user.UserID) # Find the possibly multiple mediations the landlord is involve in.
    end 

    @show_mediation_view = @mediation.present? # this is used by the view to determine if we show current mediations or if we need to show create mediations
  end

  def create

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
