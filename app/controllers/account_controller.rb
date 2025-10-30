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

  
  def enable_sms_2fa
    
    if params[:verification_code].present?
      verification_code = params[:verification_code].strip
      
      
      verifier = TwilioVerifyService.new
      verified = false
      
      if verifier.configured? && @user.phone_number.present?
        
        result = verifier.check_verification(to: @user.phone_number, code: verification_code)
        verified = result[:valid] unless result[:error]
      end
      
      
      verified = @user.verify_sms_otp(verification_code) unless verified
      
      if verified
        @user.sms_2fa_enabled = true
        if @user.save
          redirect_to account_path, notice: "SMS 2FA enabled successfully! Your phone number has been verified."
        else
          redirect_to account_path, alert: "Failed to enable SMS 2FA"
        end
      else
        redirect_to phone_verify_account_path, alert: "Invalid or expired verification code. Please try again."
      end
      return
    end

    
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
    @user.sms_2fa_enabled = false
    if @user.save
      redirect_to account_path, notice: "SMS 2FA disabled successfully"
    else
      redirect_to account_path, alert: "Failed to disable SMS 2FA"
    end
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
    @user = User.find(session[:user_id])
  end
end
