require "test_helper"

class EmailTwoFactorMailerTest < ActionMailer::TestCase
  test "verification_code" do
    mail = EmailTwoFactorMailer.verification_code
    assert_equal "Verification code", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
