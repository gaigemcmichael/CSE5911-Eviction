require "test_helper"

class MediatorCasesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get mediator_cases_show_url
    assert_response :success
  end
end
