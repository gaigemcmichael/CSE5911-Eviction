require "test_helper"

class LandlordMailerTest < ActionMailer::TestCase
  test "invitation_email" do
    invited_by_user = users(:one)
    mail = LandlordMailer.invitation_email("to@example.org", invited_by_user)
    assert_equal "You are invited to join the Mediation Platform", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_match invited_by_user.FName, mail.body.encoded
  end
end