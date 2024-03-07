require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as @user, scope: :user
    @event = events(:one)
  end

  test "visiting the index" do
    visit events_url
    assert_selector "h1", text: "Events"
  end
end
