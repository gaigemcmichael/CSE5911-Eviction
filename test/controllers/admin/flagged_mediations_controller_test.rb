require "test_helper"

class Admin::FlaggedMediationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin1)
    @mediation = primary_message_groups(:one)

    ScreeningQuestion.find(@mediation.TenantScreeningID)&.update!(flagged: true)
    ScreeningQuestion.find(@mediation.LandlordScreeningID)&.update!(flagged: true)

    post login_url, params: { email: @admin[:Email], password: "password" }
    assert_redirected_to dashboard_url
    follow_redirect!
    assert_response :success
  end

  test "lists flagged mediations for admins" do
    get admin_mediations_url

    assert_response :success
    assert_select "h1", "Mediations Dashboard"
    assert_select "table.mediation-table tbody tr", minimum: 1
  end

  test "shows a specific flagged mediation" do
    get admin_flagged_mediation_url(@mediation)

    assert_response :success
    assert_select "h1", "Flagged Mediation Details"
    assert_select ".card-header h2", text: /Tenant|Landlord/
  end
end
