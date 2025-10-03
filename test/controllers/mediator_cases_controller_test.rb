require "test_helper"

class MediatorCasesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    log_in_as(users(:admin1))
    get mediator_case_url(1)
    assert_redirected_to dashboard_url
  end
end
