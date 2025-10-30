require "test_helper"

class MediationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tenant = users(:tenant1)
    @landlord = users(:landlord1)
    @mediation = primary_message_groups(:one)
  end

  def log_in_as(user, expect_success: true)
    post login_path, params: { email: user[:Email], password: "password" }
    assert_redirected_to dashboard_url
    follow_redirect!
    assert_response(:success) if expect_success
  end

  test "tenant can create mediation" do
    log_in_as(@tenant)
    assert_difference("PrimaryMessageGroup.count") do
      post mediations_path, params: { landlord_id: @landlord[:UserID] }
    end

    new_mediation = PrimaryMessageGroup.order(:ConversationID).last
    assert_redirected_to mediation_path(new_mediation)
  end

  test "non-tenant cannot create mediation" do
    log_in_as(@landlord)
    assert_no_difference("PrimaryMessageGroup.count") do
      post mediations_path, params: { landlord_id: @landlord[:UserID] }
    end

    assert_redirected_to mediations_path
    assert_equal "Only tenants can start a negotiation.", flash[:alert]
  end

  test "landlord can accept mediation" do
    log_in_as(@landlord)

    post accept_mediation_path(@mediation)
    assert @mediation.reload.accepted_by_landlord
    assert_redirected_to mediations_path
    assert_equal "Negotiation accepted. You can now view and respond to the negotiation.", flash[:notice]
  end

  test "unauthorized landlord cannot accept mediation" do
    another_landlord = users(:landlord2)
    log_in_as(another_landlord)

    post accept_mediation_path(@mediation)
    assert_redirected_to mediations_path
    assert_equal "You are not authorized to accept this negotiation.", flash[:alert]
    assert_not @mediation.reload.accepted_by_landlord
  end

  test "require login to access mediations" do
    get new_mediation_url
    assert_redirected_to login_path
    assert_equal "You must be logged in to access the mediations.", flash[:alert]
  end

  test "require login to accept mediation" do
    post accept_mediation_path(@mediation)

    assert_redirected_to login_path
    assert_equal "You must be logged in to access the mediations.", flash[:alert]
    assert_not @mediation.reload.accepted_by_landlord
  end
end
