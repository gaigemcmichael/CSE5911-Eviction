require "test_helper"

class Admin::FlaggedMediationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_flagged_mediations_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_flagged_mediations_show_url
    assert_response :success
  end
end
