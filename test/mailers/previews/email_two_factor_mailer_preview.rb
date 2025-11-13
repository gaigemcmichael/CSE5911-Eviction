# Preview all emails at http://localhost:3000/rails/mailers/email_two_factor_mailer
class EmailTwoFactorMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/email_two_factor_mailer/verification_code
  def verification_code
    EmailTwoFactorMailer.verification_code
  end
end
