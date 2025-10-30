class SessionsController < ApplicationController
    def new
    end

    def create
        # Find user by email
        user = User.find_by(Email: params[:email])

        if user && user.authenticate(params[:password])
          if user.sms_2fa_enabled?
            session[:pre_sms_user_id] = user.UserID
            verifier = TwilioVerifyService.new
            if verifier.configured?
              result = verifier.start_verification(to: user.phone_number)
              if result[:error]
                Rails.logger.error "Twilio verify start error: #{result[:error]}"
                flash[:alert] = 'Unable to send verification, please try again later.'
                redirect_to new_session_path and return
              else
                user.update!(twilio_verification_sid: result[:sid], twilio_verification_status: result[:status], twilio_verification_sent_at: Time.current)
                redirect_to sms_two_factor_path and return
              end
            else
              code = user.generate_sms_otp
              SmsSender.send_sms(to: user.phone_number, body: "Your verification code is: #{code}")
              redirect_to sms_two_factor_path and return
            end
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
