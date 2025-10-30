class User < ApplicationRecord
  has_secure_password
  attr_accessor :ProfileDisclaimer
  validates :ProfileDisclaimer, acceptance: { accept: "yes", message: "You must agree to the Disclaimer to sign up." }

  validates :Email,
            presence: true,
            uniqueness: { case_sensitive: false, message: "is already registered" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  validates :password_confirmation, presence: true, if: -> { password.present? }

  validate :role_based_field_requirements

  has_one :mediator, foreign_key: "UserID", primary_key: "UserID", dependent: :destroy
  accepts_nested_attributes_for :mediator

  before_validation :normalize_email
  before_validation :normalize_phone_number

  def display_name
    first = self[:FirstName]
    return first if first.present?

    email = self[:Email]
    return email.split("@").first.titleize if email.present?

    "there"
  end

  def tenant?   = self[:Role] == "Tenant"
  def landlord? = self[:Role] == "Landlord"
  def mediator? = self[:Role] == "Mediator"
  def admin?    = self[:Role] == "Admin"

  def sms_2fa_enabled?
    phone_number.present? && sms_2fa_enabled == true
  end

  # SMS OTP Configuration
  SMS_OTP_TTL = 10.minutes
  SMS_OTP_MAX_ATTEMPTS = 5
  SMS_RESEND_INTERVAL = 30.seconds

  def generate_sms_otp
    code = SecureRandom.random_number(10**6).to_s.rjust(6, '0')
    digest = BCrypt::Password.create(code)
    self.sms_otp_digest = digest
    self.sms_otp_sent_at = Time.current
    self.sms_otp_expires_at = SMS_OTP_TTL.from_now
    self.sms_otp_attempts = 0
    save!
    code
  end

  def verify_sms_otp(input_code)
    return false if sms_otp_digest.blank? || sms_otp_expires_at.blank?
    return false if Time.current > sms_otp_expires_at
    return false if sms_otp_attempts.to_i >= SMS_OTP_MAX_ATTEMPTS

    self.sms_otp_attempts = (sms_otp_attempts || 0) + 1
    save!

    valid = BCrypt::Password.new(sms_otp_digest) == input_code.to_s
    if valid
      self.sms_otp_digest = nil
      self.sms_otp_expires_at = nil
      self.sms_otp_attempts = 0
      save!
      true
    else
      false
    end
  end

  def phone_number_formatted
    return nil unless phone_number.present?
    phone_number.to_s.gsub(/(\d{1})(\d{3})(\d{3})(\d{4})/, '+\1 (\2) \3-\4')
  end

  def can_send_sms_otp?
    return false unless phone_number.present?
    return false if sms_otp_attempts && sms_otp_attempts >= SMS_OTP_MAX_ATTEMPTS
    
    return true if sms_otp_sent_at.blank?
    sms_otp_sent_at < SMS_RESEND_INTERVAL.ago
  end

  validate :phone_number_must_be_valid

  private

  def normalize_phone_number
    return if self[:phone_number].blank?
    parsed = Phonelib.parse(self[:phone_number])
    if parsed.valid?
      self[:phone_number] = parsed.e164
    end
  end

  def phone_number_must_be_valid
    return if self[:phone_number].blank?
    unless Phonelib.valid?(self[:phone_number])
      errors.add(:phone_number, 'is not a valid phone number')
    end
  end

  private

  def normalize_email
    self[:Email] = self[:Email].to_s.strip.downcase
  end

  def role_based_field_requirements
    if self[:Role] == "Tenant" && self[:TenantAddress].blank?
      errors.add(:TenantAddress, "can't be blank for tenants")
    elsif self[:Role] == "Landlord" && self[:CompanyName].present? && self[:CompanyName].length > 255
      errors.add(:CompanyName, "is too long")
    end
  end
end
