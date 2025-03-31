require "test_helper"

class ThirdPartyMediationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do # think this one will need a simulated login it wants to redirect to the login page.
    get third_party_mediations_index_url
    assert_response :success
  end
end
