class ApplicationController < ActionController::Base
  allow_browser versions: { chrome: "all", safari: "all", firefox: "all", edge: "all" } # this is needed for iphones using safari to be able to view stuff.
  before_action :set_current_user

  private

  def set_current_user
    @user = User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(UserID: session[:user_id]) if session[:user_id]
  end
end
