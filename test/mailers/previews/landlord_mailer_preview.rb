# Preview all emails at http://localhost:3000/rails/mailers/landlord_mailer
class LandlordMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/landlord_mailer/invitation_email
  def invitation_email
    LandlordMailer.invitation_email
  end
end
