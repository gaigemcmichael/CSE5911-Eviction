class SessionsController < ApplicationController
    
    def new
    end

    def create
        # Find user by email
        user = User.find_by(Email: params[:email])

        if user && user.authenticate(params[:password]) # Match encrypted password
          if user.sms_2fa_enabled?
            session[:pre_sms_user_id] = user.UserID
            verifier = TwilioVerifyService.new
            if verifier.configured?
              result = verifier.start_verification(to: user.phone_number)
              if result[:error]
                Rails.logger.error "Twilio verify start error: #{result[:error]}"
                # Fallback to local OTP generation
                code = user.generate_sms_otp
                Rails.logger.info "SMS Code for #{user.phone_number}: #{code}"
                puts "*** SMS CODE: #{code} for #{user.phone_number} ***"
                redirect_to sms_two_factor_path, notice: "Please enter the verification code sent to your phone"
                return
              else
                user.update!(twilio_verification_sid: result[:sid], twilio_verification_status: result[:status], twilio_verification_sent_at: Time.current)
              end
            else
              code = user.generate_sms_otp
              code = user.generate_sms_otp
              Rails.logger.info "SMS Code for #{user.phone_number}: #{code}"
              puts "*** SMS CODE: #{code} for #{user.phone_number} ***"
            end
            
            redirect_to sms_two_factor_path, notice: "Please enter the verification code sent to your phone"
          else
            session[:user_id] = user.UserID
            redirect_to dashboard_path, notice: "Logged in successfully!"
          end
        else
          flash[:error] = "Invalid email or password"
          render :new, status: :unprocessable_entity, turbo: false
        end
    end

    def destroy
      session[:user_id] = nil
      redirect_to root_path, notice: "Logged out successfully!"
    end
end

              