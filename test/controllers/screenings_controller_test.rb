require "test_helper"
# Just a scaffold, will need filled in
class ScreeningsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @screening = screenings(:one)
  end

  test "should get index" do
    get screenings_url
    assert_response :success
  end

  test "should get new" do
    get new_screening_url
    assert_response :success
  end

  test "should create screening" do
    assert_difference("Screening.count") do
      post screenings_url, params: { screening: {} }
    end

    assert_redirected_to screening_url(Screening.last)
  end

  test "should show screening" do
    get screening_url(@screening)
    assert_response :success
  end

  test "should get edit" do
    get edit_screening_url(@screening)
    assert_response :success
  end

  test "should update screening" do
    patch screening_url(@screening), params: { screening: {} }
    assert_redirected_to screening_url(@screening)
  end

  test "should destroy screening" do
    assert_difference("Screening.count", -1) do
      delete screening_url(@screening)
    end

    assert_redirected_to screenings_url
  end
end
