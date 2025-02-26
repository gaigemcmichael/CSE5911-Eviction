require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tenant = users(:tenant) # Assume a fixture for a tenant user
    @landlord = users(:landlord) # Assume a fixture for a landlord user
    @mediation = primary_message_groups(:one) # Assume a fixture for mediation
  end

  def log_in_as(user)
    post login_path, params: { session: { email: user.Email, password: user.Password } }
  end

  test "should redirect to login if not logged in" do
    get messages_path
    assert_redirected_to login_path
    assert_equal "You must be logged in to access the dashboard.", flash[:alert]
  end

  test "tenant should see tenant_index if mediation exists" do
    log_in_as(@tenant) # Helper method to simulate login
    get messages_path
    assert_response :success
    assert_template "messages/tenant_index"
  end

  test "tenant without mediation should see landlords list" do
    @mediation.destroy # Ensure no mediation exists
    log_in_as(@tenant)
    get messages_path
    assert_response :success
    assert_template "messages/tenant_index"
    assert_not_nil assigns(:landlords)
  end

  test "landlord should see landlord_index if mediation exists" do
    log_in_as(@landlord)
    get messages_path
    assert_response :success
    assert_template "messages/landlord_index"
  end

  test "unauthorized users should get forbidden response" do
    unauthorized_user = users(:random) # Assume a fixture for unauthorized role
    log_in_as(unauthorized_user)
    get messages_path
    assert_response :forbidden
    assert_match "Access Denied", response.body
  end
end