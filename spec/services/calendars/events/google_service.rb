require "rails_helper"

RSpec.describe Calendars::Events::GoogleService do
  it "will get and create events from google calendar to master calendar" do
    events = [
      Google::Apis::CalendarV3::Event.new(
        i_cal_uid: "testing-uid",
        start: Google::Apis::CalendarV3::EventDateTime.new(date_time: DateTime.current.beginning_of_day, time_zone: "Asia/Bangkok"),
        end: Google::Apis::CalendarV3::EventDateTime.new(date_time: DateTime.current.end_of_day, time_zone: "Asia/Bangkok"),
        summary: "Testing Event",
        description: "Testing Event Description",
        event_type: "calendar#event",
        status: "confirmed",
        id: "uuid-testing"
      )
    ]

    user = create(:user)
    workspace = create(:workspace, owner: user)
    connected_account = create(:user_connected_account, user: user, provider: "google_oauth2")

    google_client = double("Google::Apis::CalendarV3::CalendarService")
    allow(GoogleOauth2Client).to receive(:new).with(connected_account).and_return(google_client)
    allow(google_client).to receive(:fetch_calendar_events).and_yield(events)
    allow(google_client).to receive(:build_webhook_channel).and_return(
      Google::Apis::CalendarV3::Channel.new
    )
    allow(google_client).to receive(:watch_event).and_return(
      Google::Apis::CalendarV3::Channel.new
    )

    allow(google_client).to receive(:sync_token).and_return("random_sync_token")
    allow(google_client).to receive(:page_token).and_return("random_page_token")

    described_class.call(user, workspace)

    google_event = workspace.events.first

    expect(workspace.events.count).to eq(1)
    expect(workspace.webhooks.count).to eq(1)
    expect(google_event.name).to eq("Testing Event")
  end
end
