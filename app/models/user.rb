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
