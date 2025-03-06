class User < ApplicationRecord
  attr_accessor :ProfileDisclaimer  # Virtual attribute (not stored in DB)
  validates :ProfileDisclaimer, acceptance: { accept: "yes", message: "You must agree to the Disclaimer to sign up." }
end
