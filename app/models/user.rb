class User < ApplicationRecord
  has_secure_password # Encrypt Passwords
  attr_accessor :ProfileDisclaimer  # Virtual attribute (not stored in DB)
  validates :ProfileDisclaimer, acceptance: { accept: "yes", message: "You must agree to the Disclaimer to sign up." }

  # User must enter a valid formated email
  validates :Email,
    presence: true,
    uniqueness: { case_sensitive: false, message: "is already registered" },
    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  # Password confirmation must match
  validates :password_confirmation, presence: true

  # Conditional validations for tenant/landlord fields
  validate :role_based_field_requirements

  def role_based_field_requirements
    if self.Role == "Tenant" && self.TenantAddress.blank?
      errors.add(:TenantAddress, "can't be blank for tenants")
    elsif self.Role == "Landlord" && self.CompanyName.present? && self.CompanyName.length > 255
      errors.add(:CompanyName, "is too long")
    end
  end

  # Associating a mediator to a user
  has_one :mediator, foreign_key: "UserID", dependent: :destroy
  accepts_nested_attributes_for :mediator
end
