class TwilioVerifyService
  def initialize
    cfg = Rails.application.credentials.dig(:twilio) || {}
    @account_sid = cfg[:account_sid].presence || ENV['TWILIO_ACCOUNT_SID']
    @auth_token  = cfg[:auth_token].presence  || ENV['TWILIO_AUTH_TOKEN']
    @service_sid = cfg[:verify_service_sid].presence || ENV['TWILIO_VERIFY_SERVICE_SID']
    @configured = @account_sid.present? && @auth_token.present? && @service_sid.present?
    return unless @configured

    require 'twilio-ruby'
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)
  end

  def configured?
    @configured
  end

  # Start a verification (sends a code). Returns a hash with :sid, :status, :to, :created_at
  def start_verification(to:)
    return { configured: false } unless configured?
    res = @client.verify.services(@service_sid).verifications.create(to: to, channel: 'sms')
    { configured: true, sid: res.sid, status: res.status, to: res.to, created_at: res.date_created }
  rescue => e
    Rails.logger.error "TwilioVerifyService.start_verification error: #{e.class} #{e.message}"
    { configured: true, error: e.message }
  end

  # Check a verification code. Returns { configured: true, sid:, status:, valid: boolean }
  def check_verification(to:, code:)
    return { configured: false } unless configured?
    res = @client.verify.services(@service_sid).verification_checks.create(to: to, code: code)
    { configured: true, sid: res.sid, status: res.status, valid: (res.status == 'approved') }
  rescue => e
    Rails.logger.error "TwilioVerifyService.check_verification error: #{e.class} #{e.message}"
    { configured: true, error: e.message }
  end
end
