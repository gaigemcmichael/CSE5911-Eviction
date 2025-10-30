class SmsTwoFactorController < ApplicationController
  
  def show
    unless session[:pre_sms_user_id]
      redirect_to new_session_path, alert: 'Session expired, please login again'
      return
    end
    @user = User.find_by(UserID: session[:pre_sms_user_id])
  end

  def verify
    @user = User.find_by(UserID: session[:pre_sms_user_id])
    unless @user
      redirect_to new_session_path, alert: 'Session expired, please login again'
      return
    end

    verifier = TwilioVerifyService.new
    if verifier.configured?
      res = verifier.check_verification(to: @user.phone_number, code: params[:otp_code])
      if res[:error]
        Rails.logger.error "Twilio verify check error: #{res[:error]}"
        flash.now[:error] = 'Verification failed due to an internal error'
        render :show, status: :unprocessable_entity and return
      elsif res[:valid]
        session[:user_id] = @user.UserID
        session.delete(:pre_sms_user_id)
        @user.update!(twilio_verification_status: res[:status])
        redirect_to dashboard_path, notice: 'Logged in successfully!'
      else
        flash.now[:error] = 'Invalid or expired code'
        render :show, status: :unprocessable_entity
      end
    else
      if @user.verify_sms_otp(params[:otp_code])
        session[:user_id] = @user.UserID
        session.delete(:pre_sms_user_id)
        redirect_to dashboard_path, notice: 'Logged in successfully!'
      else
        flash.now[:error] = 'Invalid or expired code'
        render :show, status: :unprocessable_entity
      end
    end
  end

  def resend
    @user = User.find_by(UserID: session[:pre_sms_user_id])
    unless @user
      redirect_to new_session_path, alert: 'Session expired, please login again'
      return
    end

    if @user.can_send_sms_otp?
      verifier = TwilioVerifyService.new
      if verifier.configured?
        result = verifier.start_verification(to: @user.phone_number)
        if result[:error]
          Rails.logger.error "Twilio verify resend error: #{result[:error]}"
          redirect_to sms_two_factor_path, alert: 'Unable to resend verification.'
        else
          @user.update!(twilio_verification_sid: result[:sid], twilio_verification_status: result[:status], twilio_verification_sent_at: Time.current)
          redirect_to sms_two_factor_path, notice: 'Code resent (via Twilio)'
        end
      else
        
    code = @user.generate_sms_otp
    
    Rails.logger.info "SMS Code for #{@user.phone_number}: #{code}"
    puts "*** SMS CODE: #{code} for #{@user.phone_number} ***"
    redirect_to sms_two_factor_path, notice: 'SMS verification code sent'
      end
    else
      wait_time = (@user.sms_otp_sent_at + 30.seconds - Time.current).to_i if @user.sms_otp_sent_at
      message = wait_time > 0 ? "Please wait #{wait_time} seconds before requesting another code" : 'Cannot send code at this time'
      redirect_to sms_two_factor_path, alert: message
    end
  end
end
