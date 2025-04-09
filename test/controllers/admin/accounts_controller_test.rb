require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_accounts_index_url
    assert_response :success
  end

  test "should get create" do
    get admin_accounts_create_url
    assert_response :success
  end

  test "should get update" do
    get admin_accounts_update_url
    assert_response :success
  end
end
