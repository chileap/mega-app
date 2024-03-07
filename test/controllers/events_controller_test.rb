require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_one = users(:one)
    @user_one_workspace = workspaces(:one)

    sign_in @user_one
    switch_workspace(@user_one_workspace)
    @event = events(:one)
  end

  test "should get index" do
    get events_url
    assert_response :success
  end

  test "should get new" do
    get new_event_url
    assert_response :success
  end

  test "should create event" do
    assert_difference("Event.count") do
      post events_url, params: {event: {workspace_id: @event.workspace_id, created_by_id: @event.created_by_id, description: @event.description, end_time: @event.end_time, name: @event.name, start_time: @event.start_time, time_zone: @event.time_zone}}
    end

    assert_redirected_to calendars_url
  end

  test "should show event" do
    get event_url(@event)
    assert_response :success
  end

  test "should get edit" do
    get edit_event_url(@event)
    assert_response :success
  end

  test "should update event" do
    patch event_url(@event), params: {event: {workspace_id: @event.workspace_id, created_by_id: @event.created_by_id, description: @event.description, end_time: @event.end_time, name: @event.name, start_time: @event.start_time, time_zone: @event.time_zone}}
    assert_redirected_to calendars_url
  end

  test "should destroy event" do
    assert_difference("Event.count", -1) do
      delete event_url(@event)
    end

    assert_redirected_to calendars_url
  end
end
