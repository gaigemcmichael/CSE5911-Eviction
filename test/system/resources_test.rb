require "application_system_test_case"

class ResourcesTest < ApplicationSystemTestCase
  setup do
    @tenant = users(:tenant1)
    @landlord = users(:landlord1)
  end

  test "tenant can view tenant resources guide tab" do
    sign_in_as(@tenant)
    visit resources_path(tab: "guide")
    dismiss_terms_modal_if_present

    assert_text "Tenant Resources"
    assert_text "Learn the eviction process"
  end

  test "tenant can switch FAQ categories on the resources page" do
    sign_in_as(@tenant)
    visit resources_path(tab: "guide")
    dismiss_terms_modal_if_present

    # The FAQ section opens on the first category, "General".
    assert_text "Frequently Asked Questions"
    assert_text "What is Mediation?"

    click_link "Data Privacy"
    assert_current_path resources_path(tab: "guide", category: "data-privacy")
    assert_text "Who operates this platform?"
  end

  test "tenant can open a resource card to reveal its panel" do
    sign_in_as(@tenant)
    visit resources_path(tab: "guide")
    dismiss_terms_modal_if_present

    # The "Other housing issues" panel is hidden until its card is clicked.
    assert_no_text "Security deposits"
    find(".resx-card", text: "Other housing issues").click
    assert_text "Security deposits"
  end

  test "landlord can view landlord resources guide tab" do
    sign_in_as(@landlord)
    visit resources_path(tab: "guide")
    dismiss_terms_modal_if_present

    assert_text "Landlord Resources"
    assert_text "Learn the process and how early communication can save time, fees, and turnover."
  end

  test "landlord sees the FAQ section on the resources page" do
    sign_in_as(@landlord)
    visit resources_path(tab: "guide")
    dismiss_terms_modal_if_present

    assert_text "Frequently Asked Questions"
    assert_text "What is Mediation?"
  end

  test "tenant navbar links to the resources page" do
    sign_in_as(@tenant)
    visit dashboard_path
    dismiss_terms_modal_if_present

    click_link "Resources"
    assert_current_path resources_path
    assert_text "Tenant Resources"
  end

  test "landlord navbar dropdown links to main resources tab" do
    sign_in_as(@landlord)
    visit dashboard_path
    dismiss_terms_modal_if_present

    open_nav_dropdown
    click_link "Main Resources"
    assert_current_path resources_path(tab: "guide")
    assert_text "Landlord Resources"
  end

  private

  # The landlord navbar reveals its Resources submenu on hover, which Selenium
  # cannot hold reliably, so force it open instead.
  def open_nav_dropdown
    page.execute_script("document.querySelector('.nav-dropdown-menu').style.display = 'block'")
  end

  def sign_in_as(user)
    visit login_path
    fill_in "email", with: user.Email
    fill_in "password", with: "password"
    click_button "Log In"
    dismiss_terms_modal_if_present
  end

  def dismiss_terms_modal_if_present
    return unless page.has_button?("OK", wait: 1)

    click_button "OK"
  end
end
