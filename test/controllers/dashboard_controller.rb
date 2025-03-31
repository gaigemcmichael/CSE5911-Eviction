require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @landlord = users(:landlord1)
    @tenant = users(:tenant1)
    @admin = users(:admin1)
    @mediator = users(:mediator1)
    @invalid_user = users(:invalid1)
  end

  def log_in_as(user)
    post login_path, params: { session: { email: user.Email, password: user.Password } }
  end

  test "should redirect to login if not logged in" do
    get dashboard_path
    assert_redirected_to login_path
    assert_equal "You must be logged in to access the dashboard.", flash[:alert]
  end

  test "should get index for landlord" do # have isolated this (and probably the rest of the test cases) issue due to the log_in_as method not actually logging users in. expecting <"dashboard/index"> but rendering with <["sessions/new", "layouts/application"]>
    log_in_as(@landlord)
    get dashboard_path

    if response.redirect?
      follow_redirect!  # If redirected, follow the redirect
    end

    assert_response :success
    assert_template "dashboard/index"
  end

  test "should get index for tenant" do # expecting <"dashboard/index"> but rendering with <[]>
    log_in_as(@tenant)
    get dashboard_path
    assert_response :redirect
    assert_template "dashboard/index"
  end

  test "should get index for admin" do # Not yet implemented
    log_in_as(@admin)
    get dashboard_path
    assert_response :redirect
    assert_template "dashboard/index"
  end

  test "should get index for mediator" do # expecting <"dashboard/index"> but rendering with <[]>
    log_in_as(@mediator)
    get dashboard_path
    assert_response :redirect
    assert_template "dashboard/index"
  end

  test "should deny access for invalid user role" do # Expected response to be a <403: forbidden>, but was a <302: Found> redirect to <http://www.example.com/login>
    log_in_as(@invalid_user)
    get dashboard_path
    assert_response :forbidden
    assert_equal "Error: Invalid user role", response.body
  end

  test "should log out and redirect to root" do # Expected response to be a <3XX: redirect>, but was a <404: Not Found>
    log_in_as(@landlord)
    delete logout_path
    assert_redirected_to root_path
    assert_nil session[:user_id]
    assert_equal "You have been logged out.", flash[:notice]
  end
end
