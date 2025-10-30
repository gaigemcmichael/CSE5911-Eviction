class AccountController < ApplicationController
  
  before_action :require_login
  before_action :set_user

  def show
  end

  def update
  end

  def edit
  end

  def update
    updated = false

    # Password Update
    if params[:user][:password].present?
      if @user.update(password_params)
        flash[:notice] = "Password updated successfully."
        updated = true
      else
        flash.now[:alert] = "Password update failed."
        render :show and return
      end
    end

    # Mediator Availability Update
    if @user.Role == "Mediator" && params[:user][:mediator_attributes].present?
      if @user.update(mediator_params)
        flash[:notice] ||= "Availability updated."
        updated = true
      else
        flash.now[:alert] = "Failed to update availability."
        render :show and return
      end
    end

    # Address Update
    if @user.Role == "Tenant" && params[:user][:TenantAddress].present? && params[:commit] == "Update Address"
      if @user.update(address_params)
        flash[:notice] ||= "Address updated successfully."
        updated = true
      else
        flash.now[:alert] = "Address update failed."
        render :show and return
      end
    end

    flash[:alert] = "No changes detected." unless updated
    redirect_to account_path
  end

  def send_sms_verification
    unless @user
      redirect_to login_path, alert: 'Please sign in' and return
    end

    phone = params[:phone_number].to_s.strip
    if phone.blank?
      redirect_to account_path, alert: 'Phone number cannot be blank' and return
    end

    @user.update!(phone_number: phone)
    
    unless @user.valid?
      flash[:alert] = @user.errors.full_messages.join(', ')
      redirect_to account_path and return
    end

    verifier = TwilioVerifyService.new
    if verifier.configured?
      result = verifier.start_verification(to: @user.phone_number)
      if result[:error]
        Rails.logger.error "Twilio verify send error: #{result[:error]}"
        flash[:alert] = 'Unable to send verification via Twilio. Please try again later.'
      else
        @user.update!(twilio_verification_sid: result[:sid], twilio_verification_status: result[:status], twilio_verification_sent_at: Time.current)
        flash[:notice] = 'Verification code sent to your phone (via Twilio).'
      end
    else
      code = @user.generate_sms_otp
      Rails.logger.info "SMS Code for #{@user.phone_number}: #{code}"
      puts "*** SMS CODE: #{code} for #{@user.phone_number} ***"
      flash[:notice] = 'Verification code sent to your phone.'
    end
    redirect_to account_path
  end

  def enable_sms_2fa
    unless @user
      redirect_to login_path, alert: 'Please sign in' and return
    end

    # Handle verification code submission
    if params[:verification_code].present? || params[:sms_code].present?
      verification_code = (params[:verification_code] || params[:sms_code]).strip
      
      verifier = TwilioVerifyService.new
      verified = false
      
      if verifier.configured? && @user.phone_number.present?
        result = verifier.check_verification(to: @user.phone_number, code: verification_code)
        if result[:error]
          Rails.logger.error "Twilio verify check error: #{result[:error]}"
          flash[:alert] = 'Verification failed due to an internal error.'
        elsif result[:valid]
          verified = true
        else
          flash[:alert] = 'Invalid or expired verification code.'
        end
      else
        verified = @user.verify_sms_otp(verification_code)
        flash[:alert] = 'Invalid or expired verification code.' unless verified
      end
      
      if verified
        @user.update!(sms_2fa_enabled: true)
        flash[:notice] = 'SMS two-factor enabled successfully!'
      end
      
      redirect_to account_path
      return
    end

    # Handle phone number submission
    phone = params[:phone_number]&.strip
    if phone.blank?
      redirect_to account_path, alert: "Phone number is required"
      return
    end

    @user.phone_number = phone
    @user.sms_2fa_enabled = true
    
    if @user.save
      redirect_to account_path, notice: "SMS 2FA enabled successfully"
    else
      redirect_to account_path, alert: "Failed to enable SMS 2FA"
    end
  end

  def disable_sms_2fa
    unless @user
      redirect_to login_path, alert: 'Please sign in' and return
    end
    
    Rails.logger.debug "Account#disable_sms_2fa called for user=#{@user.UserID} password_present=#{params[:password].present?} sms_code_present=#{params[:sms_code].present?}"

    disabled = false

    # Option 1: confirm current password
    if params[:password].present? && @user.authenticate(params[:password])
      disabled = @user.update(sms_2fa_enabled: false, twilio_verification_sid: nil, twilio_verification_status: nil, sms_otp_digest: nil)
      unless disabled
        Rails.logger.warn "Failed to disable SMS 2FA (password path) for user=#{@user.UserID}: #{(@user.errors.full_messages || []).join(', ')}"
        flash[:alert] = "Unable to disable SMS 2FA: #{(@user.errors.full_messages || []).join(', ')}"
      end

    # Option 2: allow disabling via SMS verification code (Verify service or local OTP)
    elsif params[:sms_code].present?
      verifier = TwilioVerifyService.new
      if verifier.configured?
        res = verifier.check_verification(to: @user.phone_number, code: params[:sms_code])
        if res[:error]
          Rails.logger.error "Twilio verify check error while disabling 2FA for user=#{@user.UserID}: #{res[:error]}"
          flash[:alert] = 'Verification failed due to an internal error.'
        elsif res[:valid]
          disabled = @user.update(sms_2fa_enabled: false, twilio_verification_sid: nil, twilio_verification_status: nil, sms_otp_digest: nil)
          flash[:notice] = 'SMS two-factor disabled via verification code.' if disabled
        else
          flash[:alert] = 'Invalid or expired verification code.'
        end
      else
        if @user.verify_sms_otp(params[:sms_code])
          disabled = @user.update(sms_2fa_enabled: false, sms_otp_digest: nil)
          flash[:notice] = 'SMS two-factor disabled via verification code.' if disabled
        else
          flash[:alert] = 'Invalid or expired verification code.'
        end
      end
    else
      # Simple disable (fallback for basic UI)
      disabled = @user.update(sms_2fa_enabled: false)
      unless disabled
        flash[:alert] = "Failed to disable SMS 2FA"
      end
    end

    if disabled && flash[:notice].blank?
      flash[:notice] = 'SMS two-factor disabled.'
    end
    redirect_to account_path
  end

  def send_test_sms
    phone = params[:phone_number]&.strip
    if phone.blank?
      render json: { success: false, error: "Phone number is required" }
      return
    end

    formatted_phone = format_phone_number(phone)
    if formatted_phone.nil?
      redirect_to phone_verify_account_path, alert: 'Invalid phone number format. Please use format: +1234567890'
      return
    end

    @user.phone_number = formatted_phone
    @user.save
    
    verifier = TwilioVerifyService.new
    if verifier.configured?
      result = verifier.start_verification(to: formatted_phone)
      if result[:error]
        code = @user.generate_sms_otp
        Rails.logger.info "SMS Code for #{formatted_phone}: #{code}"
        puts "*** SMS CODE: #{code} for #{formatted_phone} ***"
        puts "*** Twilio Error: #{result[:error] || 'Unknown error'} ***"
        redirect_to phone_verify_account_path, notice: 'Verification code generated (check console - Twilio error).'
      else
        Rails.logger.info "SMS sent successfully via Twilio Verify to #{formatted_phone}"
        puts "*** SMS SENT via Twilio Verify to #{formatted_phone} ***"
        redirect_to phone_verify_account_path, notice: 'Verification code sent to your phone via Twilio Verify.'
      end
    else
      code = @user.generate_sms_otp
      Rails.logger.info "SMS Code for #{formatted_phone}: #{code}"
      puts "*** SMS CODE: #{code} for #{formatted_phone} ***"
      puts "*** Configure Twilio Verify Service credentials to send actual SMS messages ***"
      redirect_to phone_verify_account_path, notice: 'Verification code generated (check console - configure Twilio Verify).'
    end
  end

  def phone_verify
  end

  private

  def format_phone_number(phone)
    
    digits = phone.gsub(/\D/, '')
    
    
    if digits.length == 10
      
      return "+1#{digits}"
    elsif digits.length == 11 && digits.start_with?('1')
      
      return "+#{digits}"
    elsif phone.start_with?('+')
     
      return phone
    else
      
      return nil
    end
  end

  def address_params
    params.require(:user).permit(:TenantAddress)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def mediator_params
    params.require(:user).permit(mediator_attributes: [ :id, :Available ])
  end

  def require_login
    unless session[:user_id]
      redirect_to login_path, alert: "You must be logged in to access the dashboard."
    end
  end

  def set_user
    @user = User.find_by(UserID: session[:user_id])
  end
end
