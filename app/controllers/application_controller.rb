class ApplicationController < ActionController::Base
  allow_browser versions: { chrome: "all", safari: "all", firefox: "all", edge: "all" } # this is needed for iphones using safari to be able to view stuff.
  before_action :set_current_user

  private

  def use_user_time_zone(&block)
    tz = nil
    if defined?(@user) && @user.present?
      tz = @user.try(:time_zone) || @user.try(:TimeZone) || @user.try(:Timezone)
    end
    tz ||= Rails.application.config.time_zone
    Time.use_zone(tz, &block)
  end

  def set_current_user
    @user = User.find_by(UserID: session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(UserID: session[:user_id]) if session[:user_id]
  end
end
