require "rails_helper"

RSpec.describe Events::DestroyWorkflow do
  it "should create event and push to google calendar" do
    user = create(:user)
    workspace = create(:workspace, owner: user)
    event = create(:event, workspace: workspace, created_by: user)
    connected_account = create(:user_connected_account, user: user, provider: "google_oauth2")

    google_client = double("Google::Apis::CalendarV3::CalendarService")
    allow(GoogleOauth2Client).to receive(:new).with(connected_account).and_return(google_client)
    allow(google_client).to receive(:delete_event).and_return(true)

    expect { described_class.call(event) }.to change { Event.count }.from(1).to(0)
  end
end
