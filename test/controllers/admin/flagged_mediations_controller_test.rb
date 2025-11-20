require "test_helper"

class Admin::FlaggedMediationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin1)

    # Setup unassigned mediation
    @unassigned = primary_message_groups(:one)
    @unassigned.update!(MediatorRequested: true, MediatorAssigned: false)

    # Setup completed mediation
    @completed = primary_message_groups(:two)
    @completed.update!(deleted_at: Time.current)

    post login_url, params: { email: @admin[:Email], password: "password" }
    assert_redirected_to dashboard_url
    follow_redirect!
    assert_response :success
  end

  test "lists unassigned and completed mediations for admins" do
    get admin_mediations_url

    assert_response :success
    assert_select "h1", "Mediations Dashboard"

    # Check for Unassigned section
    assert_select "h2", "Unassigned Mediator Requests"
    assert_select "td", text: /#{@unassigned.tenant.FName}/

    # Check for Completed section
    assert_select "h2", "Completed Mediations"
    assert_select "td", text: /#{@completed.tenant.FName}/
  end

  test "shows a specific mediation" do
    get admin_flagged_mediation_url(@unassigned)

    assert_response :success
    assert_select "h1", "Mediation Details"
    assert_select ".card-header h2", text: /Tenant|Landlord/
  end
end
