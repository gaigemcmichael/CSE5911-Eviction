require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @landlord = users(:landlord)
    @tenant = users(:tenant)
    @admin = users(:admin)
    @mediator = users(:mediator)
    @invalid_user = users(:invalid)
  end

  def log_in_as(user)
    post login_path, params: { session: { email: user.Email, password: user.Password } }
  end

  test "should redirect to login if not logged in" do
    get dashboard_path
    assert_redirected_to login_path
    assert_equal "You must be logged in to access the dashboard.", flash[:alert]
  end

  test "should get index for landlord" do
    log_in_as(@landlord)
    get dashboard_path
    assert_response :success
    assert_template "dashboard/index"
  end

  test "should get index for tenant" do
    log_in_as(@tenant)
    get dashboard_path
    assert_response :success
    assert_template "dashboard/index"
  end

  test "should get index for admin" do
    log_in_as(@admin)
    get dashboard_path
    assert_response :success
    assert_template "dashboard/index"
  end

  test "should get index for mediator" do
    log_in_as(@mediator)
    get dashboard_path
    assert_response :success
    assert_template "dashboard/index"
  end

  test "should deny access for invalid user role" do
    log_in_as(@invalid_user)
    get dashboard_path
    assert_response :forbidden
    assert_equal "Error: Invalid user role", response.body
  end

  test "should log out and redirect to root" do
    log_in_as(@landlord)
    delete logout_path
    assert_redirected_to root_path
    assert_nil session[:user_id]
    assert_equal "You have been logged out.", flash[:notice]
  end
end
