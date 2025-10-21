require "test_helper"

class ScreeningsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tenant = users(:tenant1)
    @mediation = primary_message_groups(:one)
  end

  def log_in_as(user, expect_success: true)
    post login_path, params: { email: user[:Email], password: "password" }
    assert_redirected_to dashboard_url
    follow_redirect!
    assert_response(:success) if expect_success
  end

  test "requires login to access screening form" do
    get new_screening_url(@mediation.ConversationID)

    assert_redirected_to login_path
    assert_equal "You must be logged in to access the dashboard.", flash[:alert]
  end

  test "tenant can view screening form" do
    log_in_as(@tenant)

    get new_screening_url(@mediation.ConversationID)

    assert_response :success
    assert_select "form"
  end

  test "tenant can submit screening responses" do
    log_in_as(@tenant)

    params = {
      screening_question: {
        UserID: @tenant[:UserID],
        InterpreterNeeded: false,
        DisabilityAccommodation: false,
        DisabilityExplanation: "",
        ConflictOfInterest: false,
        SpeakOnOwnBehalf: true,
        NeedToConsult: false,
        ConsultExplanation: "",
        RelationshipToOtherParty: "Landlord",
        Unsafe: false,
        UnsafeExplanation: ""
      },
      conversation_id: @mediation.ConversationID
    }

    assert_difference("ScreeningQuestion.count", 1) do
      post screenings_path, params: params
    end

    @mediation.reload

    assert_redirected_to message_path(@mediation.ConversationID)
    assert_not_nil @mediation.TenantScreeningID
    assert_equal "Screening completed successfully.", flash[:notice]
  end
end
