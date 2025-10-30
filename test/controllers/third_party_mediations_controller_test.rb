require "test_helper"

class ThirdPartyMediationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mediator_user = users(:mediator1)
  end

  def log_in_as(user, expect_success: true)
    post login_path, params: { email: user[:Email], password: "password" }
    assert_redirected_to dashboard_url
    follow_redirect!
    assert_response(:success) if expect_success
  end

  test "should get index" do
    log_in_as(@mediator_user)

    get third_party_mediations_url
    assert_response :success
  end
end
