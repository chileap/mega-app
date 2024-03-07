require "rails_helper"

RSpec.describe Calendars::Events::AppleService do
  let(:status) { "confirmed" }
  let(:uid) { "C191WEW2A-7CE5-4484-BC9B-EA4-BF2C24" }
  let(:events) {
    [
      [Calendav::Event.new(
        url: "https://p123-caldav.icloud.com/",
        calendar_data: "BEGIN:VCALENDAR\r\nCALSCALE:GREGORIAN\r\nPRODID:-//Apple Inc.//macOS 13.1//EN\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nCREATED:20230113T112223Z\r\nDTEND;TZID=Asia/Kathmandu:20230116T061500\r\nDTSTAMP:20230113T112224Z\r\nDTSTART;TZID=Asia/Kathmandu:20230116T051500\r\nLAST-MODIFIED:20230113T112223Z\r\nSEQUENCE:0\r\nSUMMARY:Testing Event\r\nUID:#{uid}\r\nSTATUS:#{status}\r\nTRANSP:OPAQUE\r\nEND:VEVENT\r\nBEGIN:VTIMEZONE\r\nTZID:Asia/Kathmandu\r\nX-LIC-LOCATION:Asia/Kathmandu\r\nBEGIN:STANDARD\r\nDTSTART:19200101T000000\r\nRDATE:19200101T000000\r\nTZNAME:+0530\r\nTZOFFSETFROM:+054116\r\nTZOFFSETTO:+0530\r\nEND:STANDARD\r\nBEGIN:STANDARD\r\nDTSTART:19860101T000000\r\nRDATE:19860101T000000\r\nTZNAME:+0545\r\nTZOFFSETFROM:+0530\r\nTZOFFSETTO:+0545\r\nEND:STANDARD\r\nEND:VTIMEZONE\r\nEND:VCALENDAR\r\n",
        etag: "123".to_json,
        event_url: "https://p123-caldav.icloud.com/123/calendar/test.ics"
      )]
    ]
  }

  let(:user) { create(:user) }
  let(:workspace) { create(:workspace, owner: user) }

  before {
    apple_client = double("Caldev::Client")
    allow_any_instance_of(AppleClient).to receive(:client).and_return(apple_client)
    create(:user_connected_account, user: user, provider: "apple")
    allow_any_instance_of(AppleClient).to receive(:fetch_calendar_events).and_return(events)
  }

  context "when calender is not sync" do
    context "and status is not cancelled" do
      it "will get and create events from apple calendar to master calendar" do
        expect { described_class.call(user, workspace) }.to change { Event.count }.from(0).to(1)
        event = workspace.events.first
        expect(event.name).to eq("Testing Event")
      end
    end
    context "and event status is cancelled" do
      let(:status) { "cancelled" }
      context "and event is present" do
        let!(:event) { create(:event, i_cal_uid: uid, workspace: workspace, created_at: user) }
        it "destroy event" do
          expect { described_class.call(user, workspace) }.to change { Event.count }.from(1).to(0)
        end
      end
      context "and event is not present" do
        it "does not create event" do
          expect(workspace.events.count).to eq(0)
        end
      end
    end
  end
end
