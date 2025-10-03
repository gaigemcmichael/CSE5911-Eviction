require "test_helper"

class Admin::FlaggedMediationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    log_in_as(users(:admin1))
    get admin_mediations_url
    assert_response :success
  end

  test "should get show" do
    log_in_as(users(:admin1))
    get admin_mediation_url(id: 1)
    assert_response :success
  end
end
