class TwilioService
  def initialize
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
    @verify_service_sid = ENV['TWILIO_VERIFY_SERVICE_SID']
  end

  def send_verification_code(to_number, code = nil)
    
    if @verify_service_sid.blank? || ENV['TWILIO_ACCOUNT_SID'].blank?
      Rails.logger.info "=" * 80
      Rails.logger.info "2FA VERIFICATION CODE (Development Mode - No Credentials)"
      Rails.logger.info "Phone: #{to_number}"
      Rails.logger.info "Code: #{code}"
      Rails.logger.info "=" * 80
      puts "=" * 80
      puts "2FA CODE: #{code}"
      puts "=" * 80
      return true
    end

    
    Rails.logger.info "Sending verification SMS to #{to_number} via Twilio Verify"
    @client.verify
      .v2
      .services(@verify_service_sid)
      .verifications
      .create(to: to_number, channel: 'sms')
    
    Rails.logger.info "✓ SMS sent successfully to #{to_number}"
    true
  rescue Twilio::REST::RestError => e
    Rails.logger.error "Twilio Error: #{e.message}"
    
   
    if Rails.env.development?
      Rails.logger.warn "⚠️  Twilio failed in development (likely rate limited) - using local fallback"
      Rails.logger.info "=" * 80
      Rails.logger.info "2FA VERIFICATION CODE (Twilio Failed - Using Local Code)"
      Rails.logger.info "Phone: #{to_number}"
      Rails.logger.info "Code: #{code}"
      Rails.logger.info "=" * 80
      puts "=" * 80
      puts "⚠️  RATE LIMITED - Use this code: #{code}"
      puts "=" * 80
      return true
    end
    
    false
  end

  def verify_code(to_number, code)
    
    return false if @verify_service_sid.blank?
    
    Rails.logger.info "Verifying code via Twilio Verify API for #{to_number}"
    verification_check = @client.verify
      .v2
      .services(@verify_service_sid)
      .verification_checks
      .create(to: to_number, code: code)
    
    result = verification_check.status == 'approved'
    Rails.logger.info "Twilio verification result: #{result ? '✓ Approved' : '✗ Rejected'}"
    result
  rescue Twilio::REST::RestError => e
    Rails.logger.error "Twilio Verification Error: #{e.message}"
    
    false
  end

  def generate_code
    SecureRandom.random_number(900000) + 100000  
  end
end
