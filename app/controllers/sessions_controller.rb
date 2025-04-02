class SessionsController < ApplicationController
    def new
    end

    def create
        # Find user by email
        user = User.find_by(Email: params[:email])

        # Directly compare the plain text password
        if user && user.authenticate(params[:password]) # Match encrypted password
          session[:user_id] = user.UserID
          redirect_to dashboard_path, notice: "Logged in successfully!"
        else
          flash[:alert] = "Invalid email or password"
          render :new
        end
    end

    def destroy
      session[:user_id] = nil
      redirect_to root_path, notice: "Logged out successfully!"
    end
end
