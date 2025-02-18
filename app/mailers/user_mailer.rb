class UserMailer < ApplicationMailer
  default from: "cse5915.eviction1@gmail.com" # Change To Sender's Email

  def welcome_email(user)
    @user = user
    mail(to: @user.Email, subject: "Welcome to Eviction1 Site!")
  end
end
