class MediationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_tenant_or_landlord_role, only: [:index, :create, :respond]

  

  private 

  def require_tenant_or_landlord_role
    unless ["Tenant", "Landlord"].include?(current_user.Role)
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end
end
