class UserMailer < ApplicationMailer
  # Default sender email pulled securely from Rails credentials
  default from: Rails.application.credentials.dig(:smtp, :from) || "Eviction Mediation <no-reply@example.com>"

  def welcome_email(user)
    @user = user
    @app_name = "Eviction Mediation"
    @dashboard_url = root_url
    mail(
      to: @user.Email,
      subject: "Welcome to #{@app_name}"
    )
  end
end
