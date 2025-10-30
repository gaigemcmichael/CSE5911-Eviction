class TwoFactorController < ApplicationController
  def show
    # shown when user has passed password auth and needs to enter OTP
    unless session[:pre_2fa_user_id]
      redirect_to new_session_path, alert: "Session expired, please login again"
      return
    end
    @user = User.find_by(UserID: session[:pre_2fa_user_id])
  end

  def verify
    @user = User.find_by(UserID: session[:pre_2fa_user_id])
    unless @user
      redirect_to new_session_path, alert: "Session expired, please login again"
      return
    end

    if @user.verify_otp(params[:otp_code])
      session[:user_id] = @user.UserID
      session.delete(:pre_2fa_user_id)
      redirect_to dashboard_path, notice: "Logged in successfully!"
    else
      flash.now[:error] = "Invalid authentication code"
      render :show, status: :unprocessable_entity
    end
  end

  # Account setup: show QR + manual secret to logged-in user
  def setup
    @user = current_user
    unless @user
      redirect_to new_session_path, alert: "Please sign in to manage two-factor settings"
      return
    end

    @secret = @user.otp_secret.presence || @user.generate_otp_secret
    @provisioning_uri = @user.totp.provisioning_uri(@user.Email)

    # Build an inline SVG QR code for the provisioning URI using rqrcode
    begin
      qrcode = RQRCode::QRCode.new(@provisioning_uri)
      @qr_svg = qrcode.as_svg(offset: 0, color: '000', shape_rendering: 'crispEdges', module_size: 6)
    rescue => e
      Rails.logger.error "Failed to generate QR SVG: #{e.class} #{e.message}"
      @qr_svg = nil
    end
  end

  def enable
    @user = current_user
    unless @user
      redirect_to new_session_path, alert: "Please sign in to manage two-factor settings"
      return
    end

    if @user.verify_otp(params[:otp_code])
      @user.update!(otp_enabled: true)
      redirect_to account_path, notice: "Two-factor authentication enabled"
    else
      flash.now[:error] = "Invalid code"
      render :setup, status: :unprocessable_entity
    end
  end

  def disable
    @user = current_user
    unless @user
      redirect_to new_session_path, alert: "Please sign in to manage two-factor settings"
      return
    end

    if @user.authenticate(params[:password])
      @user.update!(otp_enabled: false, otp_secret: nil)
      redirect_to account_path, notice: "Two-factor authentication disabled"
    else
      redirect_to account_path, alert: "Incorrect password"
    end
  end
end
