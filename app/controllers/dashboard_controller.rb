class DashboardController < ApplicationController
    before_action :require_login
  
    def index
        @user = User.find(session[:user_id])
    end

    def destroy
        session[:user_id] = nil  # Remove the user from the session
        redirect_to root_path, notice: "You have been logged out."  # Redirect to home page or login page
    end
  
    private
  
    def require_login
      unless session[:user_id]
        redirect_to login_path, alert: "You must be logged in to access the dashboard."
      end
    end
  end