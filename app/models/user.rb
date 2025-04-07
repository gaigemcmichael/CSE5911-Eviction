class User < ApplicationRecord
    attr_accessor :ProfileDisclaimer  # Virtual attribute (not stored in DB)
    has_secure_password
    validates :ProfileDisclaimer, acceptance: { accept: "yes", message: "You must agree to the Disclaimer to sign up." }
    def email
      self[:Email]
    end

    def password
      self[:Password]
    end

    def user_id
      self[:UserID]
    end
end
