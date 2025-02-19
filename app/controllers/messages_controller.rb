class MessagesController < ApplicationController
  before_action :require_login
  before_action :set_user

  def index
    case @user.Role
    when "Tenant"
      @landlords = User.where(Role: 'Landlord').order(:CompanyName)
      render "messages/tenant_index"
    when "Landlord"
      render "messages/landlord_index"
    else
      render plain: "Access Denied", status: :forbidden
    end
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
end
