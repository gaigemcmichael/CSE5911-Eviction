require "test_helper"

class ThirdPartyMediationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get third_party_mediations_index_url
    assert_response :success
  end
end
