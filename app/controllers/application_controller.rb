class ApplicationController < ActionController::Base
    # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
    allow_browser versions: :modern
    before_action :set_current_user

    private
  
    def set_current_user
      @user = User.find(session[:user_id]) if session[:user_id]
    end
end
