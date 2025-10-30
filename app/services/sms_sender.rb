class SmsSender
  
  def self.send_sms(to:, body:)
    # Normalize simple formatting (not a full E.164 validator)
    to = to.to_s.strip
    # Resolve Twilio credentials: prefer Rails encrypted credentials, fall back to ENV
    twilio_config = Rails.application.credentials.dig(:twilio) || {}
    account_sid = twilio_config[:account_sid].presence || ENV['TWILIO_ACCOUNT_SID']
    auth_token  = twilio_config[:auth_token].presence  || ENV['TWILIO_AUTH_TOKEN']
    from_number = twilio_config[:phone_number].presence || ENV['TWILIO_PHONE_NUMBER']

    # Development / test: still log if no provider configured, but allow real sends if creds supplied
    if (Rails.env.development? || Rails.env.test?) && account_sid.blank? && auth_token.blank? && from_number.blank?
      Rails.logger.info "SMS (dev): to=#{to} body=#{body}"
      return { success: true, provider: 'log' }
    end

    if account_sid.present? && auth_token.present? && from_number.present?
      require 'twilio-ruby'
      client = Twilio::REST::Client.new(account_sid, auth_token)
      msg = client.messages.create(from: from_number, to: to, body: body)
      Rails.logger.info "SMS sent via Twilio: sid=#{msg.sid} to=#{to}"
      return { success: true, provider: 'twilio', sid: msg.sid }
    else
      Rails.logger.error "SmsSender: Twilio credentials missing (credentials or ENV), message not sent"
      return { success: false, error: 'twilio_not_configured' }
    end
  rescue => e
    Rails.logger.error "SmsSender error: #{e.class} #{e.message}"
    { success: false, error: e.message }
  end
end
