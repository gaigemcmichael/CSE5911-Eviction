class EmailTwoFactorMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.email_two_factor_mailer.verification_code.subject
  #
  def verification_code
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
