require "icalendar/tzinfo"

class YahooClient
  TIME_MIN = 3.months.ago.rfc3339
  YAHOOL_CALDAV_URL = "https://caldav.calendar.yahoo.com".freeze

  attr_reader :account

  def initialize(account)
    @account = account
  end

  def client
    @client ||= begin
      credentials = Calendav::Credentials::Standard.new(
        host: YAHOOL_CALDAV_URL,
        username: account.email,
        password: account.app_specific_password,
        authentication: :basic_auth # or :bearer_token
      )
      Calendav.client(credentials)
    end
  end

  def fetch_calendar_events
    personal_calendar = client.calendars.list.find { |cal| cal.display_name == "My Calendars" }
    client.events.list(personal_calendar.url, from: TIME_MIN.to_datetime)
  end

  def get_event(event_url)
    client.events.find(event_url)
  end

  def insert_event(event)
    identifier = "#{SecureRandom.uuid}.ics"
    client.events.create(client.calendars.list.first.url, identifier, create_icalendar(event).to_ical)
  end

  def update_event(event)
    client.events.update(event.event_url, create_icalendar(event).to_ical)
  end

  def upsert_event(event)
    if event.event_url.blank?
      insert_event(event)
    else
      update_event(event)
    end
  end

  def delete_event(event)
    client.events.delete(event.event_url, etag: event.etag)
  end

  private

  def create_icalendar(event)
    ics = Icalendar::Calendar.new

    event_start = Icalendar::Values::DateTime.new(event.start_time)
    event_end = Icalendar::Values::DateTime.new(event.end_time)

    if event.all_day
      event_start = Icalendar::Values::Date.new(event.start_time)
      event_end = Icalendar::Values::Date.new(event.end_time)
    end

    ics.event do |e|
      e.dtstart = event_start
      e.dtend = event_end
      e.summary = Icalendar::Values::Text.new event.name
      e.description = Icalendar::Values::Text.new event.description if event.description
      e.rrule = event.ical_recurrence if event.ical_recurrence
    end
    ics.publish
    ics
  end

  def fetch_apple_events(calendar_url)
    client.events.list(calendar_url, from: TIME_MIN.to_datetime)
  end

  def change_calendar_events(collection)
    collection.changes.collect do |event|
      event.unloaded? ? client.events.find(event.url) : event
    end
  end

  def delete_calendar_events(collection)
    i_cal_uids = collection.deletions.map { |event_url| event_url&.split("/")&.[](-1)&.remove(".ics") }
    Event.where(i_cal_uid: i_cal_uids).destroy_all
  end
end
