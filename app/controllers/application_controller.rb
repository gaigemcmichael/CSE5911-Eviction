class ApplicationController < ActionController::Base
  if Rails.env.development?
    allow_browser versions: { chrome: "all", safari: "all", firefox: "all", edge: "all" } # this seems to allow iphone 14 to view all pages
  else
    allow_browser versions: :modern # We had this before but it did not allow Iphone 14 on safari to view most pages
  end
  before_action :set_current_user

  private

  def set_current_user
    @user = User.find(session[:user_id]) if session[:user_id]
  end
end
