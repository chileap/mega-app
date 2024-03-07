require "rails_helper"

RSpec.describe Events::UpdateWorkflow do
  it "should update event and push to google calendar" do
    user = create(:user)
    workspace = create(:workspace, owner: user)
    event = create(:event, workspace: workspace, created_by: user)
    connected_account = create(:user_connected_account, user: user, provider: "google_oauth2", workspace: workspace)

    google_client = double("Google::Apis::CalendarV3::CalendarService")
    allow(GoogleOauth2Client).to receive(:new).with(connected_account).and_return(google_client)
    allow(google_client).to receive(:insert_event).and_return(
      Google::Apis::CalendarV3::Event.new(
        i_cal_uid: "testing-uid",
        event_type: "calendar#event",
        status: "confirmed",
        id: "uuid-testing",
        html_link: "https://www.google.com/calendar/event?eid=uuid-testing"
      )
    )

    params = {
      name: "Testing Event",
      description: "New Event",
      sync_services: ["google_oauth2"]
    }

    event = described_class.call(event, params)
    expect(event.calendar_services.count).to eq(1)
    expect(event.calendar_services.first.i_cal_uid).to eq("testing-uid")
    expect(event.calendar_services.first.source_id).to eq("uuid-testing")
    expect(event.name).to eq("Testing Event")
  end
end
