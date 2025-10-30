require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    clear_enqueued_jobs
  end

  test "renders the signup form" do
    get signup_url

    assert_response :success
    assert_select "form"
  end

  test "creates a user with valid data" do
    params = {
      Email: "new-tenant@example.com",
      password: "Password!23",
      password_confirmation: "Password!23",
      FName: "New",
      LName: "Tenant",
      Role: "Tenant",
      TenantAddress: "123 Main St",
      ProfileDisclaimer: "yes"
    }

    assert_enqueued_jobs 1 do
      assert_difference("User.count", 1) do
        post signup_url, params: { user: params }
      end
    end

    created_user = User.find_by(Email: "new-tenant@example.com")
    assert_redirected_to dashboard_url
    assert_equal created_user.UserID, session[:user_id]
    assert_equal "Account created successfully!", flash[:notice]
  end

  test "re-renders the form when data is invalid" do
    assert_no_difference("User.count") do
      post signup_url, params: { user: { Email: "", password: "", ProfileDisclaimer: "no" } }
    end

    assert_response :success
    assert_select "form"
  end
end
