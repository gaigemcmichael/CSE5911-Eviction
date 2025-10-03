require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    log_in_as(users(:admin1))
    get admin_accounts_url
    assert_response :success
  end

  test "should get new" do
    skip "Admin accounts controller doesn't have new action - only index, create, update"
  end

  test "should create account" do
    log_in_as(users(:admin1))
    post admin_accounts_url, params: { account: { name: "Test" } }
    assert_redirected_to admin_accounts_url
  end

  test "should update account" do
    log_in_as(users(:admin1))
    patch admin_account_url(1), params: { account: { name: "Updated" } }
    assert_redirected_to admin_accounts_url
  end
end
