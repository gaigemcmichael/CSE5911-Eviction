class SmsTwoFactorController < ApplicationController
  before_action :require_pending_2fa, only: [:show, :verify, :resend]

  def show
   
  end

  def verify
    user = User.find(session[:pending_user_id])
    twilio = TwilioService.new
    code_valid = false
    
    
    if ENV['TWILIO_VERIFY_SERVICE_SID'].present?
      begin
        code_valid = twilio.verify_code(user.phone_number, params[:code])
      rescue => e
        Rails.logger.warn "Twilio verification failed: #{e.message}, falling back to local code"
        code_valid = false
      end
      
      
      if !code_valid && Rails.env.development? && user.two_factor_code.present?
        code_valid = user.two_factor_code == params[:code] && 
                     user.two_factor_code_sent_at && 
                     user.two_factor_code_sent_at > 10.minutes.ago
      end
    else
      
      code_valid = user.two_factor_code == params[:code] && 
                   user.two_factor_code_sent_at && 
                   user.two_factor_code_sent_at > 10.minutes.ago
    end
    
    if code_valid
      # Code is valid
      session[:user_id] = user.UserID
      session.delete(:pending_user_id)
      
      # Clear the 2FA code
      user.update(two_factor_code: nil, two_factor_code_sent_at: nil)
      
      redirect_to dashboard_path, notice: "Successfully logged in!"
    else
      flash[:alert] = "Invalid or expired verification code"
      redirect_to sms_two_factor_path
    end
  end

  def resend
    user = User.find(session[:pending_user_id])
    twilio = TwilioService.new
    code = twilio.generate_code
    
    
    if user.update(two_factor_code: code.to_s, two_factor_code_sent_at: Time.current)
      
      if twilio.send_verification_code(user.phone_number, code)
        flash[:notice] = "Verification code resent successfully"
      else
        flash[:alert] = "Failed to resend code. Please try again."
      end
    else
      flash[:alert] = "Failed to resend code. Please try again."
    end
    
    redirect_to sms_two_factor_path
  end

  private

  def require_pending_2fa
    unless session[:pending_user_id]
      redirect_to login_path, alert: "Please log in first"
    end
  end
end
