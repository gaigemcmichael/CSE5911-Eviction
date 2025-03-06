class MediatorCasesController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :authorize_mediator
  before_action :set_mediation, only: [ :show ]

  def show
  end

  private

  def set_mediation
    @mediation = PrimaryMessageGroup.find(params[:id])
  end

  def require_login
    unless session[:user_id]
      redirect_to login_path, alert: "You must be logged in to access the dashboard."
    end
  end

  def set_user
    @user = User.find(session[:user_id])
  end

  def authorize_mediator
    unless @user.Role == "Mediator"
      redirect_to dashboard_path, alert: "Access Denied"
    end
  end
end
