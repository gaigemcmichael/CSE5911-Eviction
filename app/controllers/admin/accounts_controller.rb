class Admin::AccountsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :authorize_admin

  def index
    @mediators = Mediator.includes(:user).all
  end

  def create
    user = User.create!(
      Email: params[:email],
      FName: params[:fname],
      LName: params[:lname],
      Role: "Mediator",
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    Mediator.create!(
      UserID: user.UserID,
      Available: true,
      MediationCap: params[:mediation_cap],
      ActiveMediations: 0
    )

    redirect_to admin_accounts_path, notice: "Mediator account created."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_accounts_path, alert: "Error creating mediator: #{e.message}"
  end

  def update
    user = User.find(params[:id])
    mediator = Mediator.find_by!(UserID: user.UserID)

    # Update Mediator model
    if params[:mediation_cap].present?
      mediator.update!(MediationCap: params[:mediation_cap])
    end

    # Update password (User model)
    if params[:password].present?
      user.update!(password: params[:password])
    end

    redirect_to "#{admin_accounts_path}#reset", notice: "Mediator updated successfully."     # Need this line so that javascript refreshes
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_accounts_path, alert: "Mediator not found."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_accounts_path, alert: "Update failed: #{e.message}"
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

  def authorize_admin
    unless @user.Role == "Admin"
      redirect_to dashboard_path, alert: "Access Denied"
    end
  end
end
