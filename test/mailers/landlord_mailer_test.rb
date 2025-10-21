require "test_helper"
require "cgi"

class LandlordMailerTest < ActionMailer::TestCase
  test "invitation_email" do
    previous_sender = ENV["GMAIL_USERNAME"]
    ENV["GMAIL_USERNAME"] = "notifications@example.com"

    inviter = users(:tenant1)
    recipient_email = "new-landlord@example.com"

    mail = LandlordMailer.invitation_email(recipient_email, inviter)

    assert_equal [ recipient_email ], mail.to
    assert_equal [ "notifications@example.com" ], mail.from
    assert_equal "You are invited to join the Mediation Platform", mail.subject
  assert_includes mail.body.encoded, inviter.FName
  escaped_query = CGI.escapeHTML("signup?role=Landlord&email=#{CGI.escape(recipient_email)}")
  assert_includes mail.body.encoded, escaped_query
  ensure
    ENV["GMAIL_USERNAME"] = previous_sender
  end
end
