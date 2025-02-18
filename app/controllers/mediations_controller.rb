class MediationsController < ApplicationController
  before_action :require_login
  before_action :require_tenant_or_landlord_role, only: [:index, :create, :respond]



  private 

  def require_login
    unless session[:user_id]
      redirect_to login_path, alert: "You must be logged in to access the dashboard."
    end
  end

  def require_tenant_or_landlord_role
    unless ["Tenant", "Landlord"].include?(current_user.Role)
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end
end
