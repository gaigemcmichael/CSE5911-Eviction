class AccountController < ApplicationController
  before_action :require_login
  before_action :set_user

  def show
  end

  def update
  end

  def edit
  end

  def update
    updated = false
  
    # Password Update
    if params[:user][:password].present?
      if @user.update(password_params)
        flash[:notice] = "Password updated successfully."
        updated = true
      else
        flash.now[:alert] = "Password update failed."
        render :show and return
      end
    end
  
    # Mediator Availability Update
    if @user.Role == "Mediator" && params[:user][:mediator_attributes].present?
      if @user.update(mediator_params)
        flash[:notice] ||= "Availability updated."
        updated = true
      else 
        flash.now[:alert] = "Failed to update availability."
        render :show and return
      end
    end
  
    # Address Update
    if @user.Role == "Tenant" && params[:user][:TenantAddress].present? && params[:commit] == "Update Address"
      if @user.update(address_params)
        flash[:notice] ||= "Address updated successfully."
        updated = true
      else
        flash.now[:alert] = "Address update failed."
        render :show and return
      end
    end
  
    flash[:alert] = "No changes detected." unless updated
    redirect_to account_path
  end

  private

  def address_params
    params.require(:user).permit(:TenantAddress)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def mediator_params
    params.require(:user).permit(mediator_attributes: [ :id, :Available ])
  end

  def require_login
    unless session[:user_id]
      redirect_to login_path, alert: "You must be logged in to access the dashboard."
    end
  end

  def set_user
    @user = User.find(session[:user_id])
  end
end
