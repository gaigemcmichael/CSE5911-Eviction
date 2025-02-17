class AccountController < ApplicationController
  before_action :require_login
  before_action :set_user

  def show
  end

  def update
  end

  def edit
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
