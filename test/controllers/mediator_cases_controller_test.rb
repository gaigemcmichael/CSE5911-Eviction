require "test_helper"

class MediatorCasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mediator_user = users(:mediator1)
    @mediation = primary_message_groups(:one)
  end

  def log_in_as(user, expect_success: true)
    post login_path, params: { email: user[:Email], password: "password" }
    assert_redirected_to dashboard_url
    follow_redirect!
    assert_response(:success) if expect_success
  end

  test "should get show" do
    log_in_as(@mediator_user)

    get mediator_case_url(@mediation)
    assert_response :success
  end
end
