require "test_helper"

class ThirdPartyMediationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    log_in_as(users(:admin1))
    get third_party_mediations_url
    assert_redirected_to dashboard_url
  end
end
