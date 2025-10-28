require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin1)
    @mediator_user = users(:mediator1)
    @mediator = mediators(:mediator1)
  end

  def log_in_as(user, expect_success: true)
    post login_path, params: { email: user[:Email], password: "password" }
    assert_redirected_to dashboard_url
    follow_redirect!
    assert_response(:success) if expect_success
  end

  test "requires login for index" do
    get admin_accounts_path
    assert_redirected_to login_path
    assert_equal "You must be logged in to access the dashboard.", flash[:alert]
  end

  test "admin can view mediator accounts" do
    log_in_as(@admin)

    get admin_accounts_path

    assert_response :success
    assert_select "h1", text: /Mediator/i, count: 1
  end

  test "admin can create mediator account" do
    log_in_as(@admin)

    params = {
      email: "new-mediator@example.com",
      fname: "New",
      lname: "Mediator",
      password: "Secret!23",
      password_confirmation: "Secret!23",
      mediation_cap: 4
    }

    assert_difference([ "User.count", "Mediator.count" ], 1) do
      post admin_accounts_path, params: params
    end

    assert_match %r{\A#{Regexp.escape(admin_accounts_url)}}, response.redirect_url
    assert_equal "Mediator account created.", flash[:notice]
  end

  test "admin can update mediator account" do
    log_in_as(@admin)

    patch admin_account_path(@mediator_user), params: {
      mediation_cap: 7
    }

    assert_match %r{\A#{Regexp.escape(admin_accounts_url)}}, response.redirect_url
    assert_equal 7, @mediator.reload.MediationCap
  end
end
