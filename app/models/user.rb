class User < ApplicationRecord
  has_secure_password # Encrypt Passwords
  attr_accessor :ProfileDisclaimer  # Virtual attribute (not stored in DB)
  validates :ProfileDisclaimer, acceptance: { accept: "yes", message: "You must agree to the Disclaimer to sign up." }

  # User must enter a valid formated email
  validates :Email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  # Associating a mediator to a user
  has_one :mediator, foreign_key: "UserID", dependent: :destroy
  accepts_nested_attributes_for :mediator
end
