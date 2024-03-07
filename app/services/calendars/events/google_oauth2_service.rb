class Calendars::Events::GoogleOauth2Service < Calendars::BaseCalendarService
  attr_reader :current_user, :workspace

  def sync_calendar_events(workspace = nil, current_user = nil)
    @current_user = current_user || account.user
    @workspace = workspace || account.workspace
    fetch_calendar_events(workspace)

    if account.webhook.blank? || account.webhook.expired?
      Calendars::Webhooks::GoogleOauth2Service.new(account).upsert_webhook
    else
      account.webhook.update!(next_sync_token: client.sync_token)
    end
  end

  def fetch_calendar_events(workspace = nil)
    client.fetch_calendar_events do |events|
      next if events.blank?
      add_to_master_calendar_events(events, workspace)
    end
  end

  def upsert_event(event)
    if event.calendar_services.find_by(provider: "google_oauth2").present?
      update_event(event)
    else
      insert_event(event)
    end
  end

  def insert_event(event)
    google_event = client.insert_event(event)
    calendar_service = event.calendar_services.find_or_create_by(
      event_id: event.id,
      provider: "google_oauth2",
      name: "Google Calendar"
    )

    calendar_service.update!(
      event_id: event.id,
      source_id: google_event.id,
      i_cal_uid: google_event.i_cal_uid,
      import_type: "local",
      imported_by_id: event.created_by_id,
      url: google_event.html_link,
      etag: google_event.etag.present? ? JSON.parse(google_event.etag) : nil,
      payload: google_event&.to_json
    )
    event
  end

  def update_event(event)
    google_event = client.update_event(event)
    calendar_service = event.calendar_services.find_or_create_by(
      event_id: event.id,
      provider: "google_oauth2",
      name: "Google Calendar"
    )

    calendar_service.update!(
      event_id: event.id,
      source_id: google_event.id,
      i_cal_uid: google_event.i_cal_uid,
      import_type: "local",
      imported_by_id: event.created_by_id,
      url: google_event.html_link,
      etag: google_event.etag.present? ? JSON.parse(google_event.etag) : nil,
      payload: google_event&.to_json
    )

    event
  end

  def delete_event(event)
    client.delete_event(event)
    calendar_service = CalendarService.find_by(
      event_id: event.id,
      provider: "google_oauth2",
      name: "Google Calendar",
      i_cal_uid: event.i_cal_uid
    )
    calendar_service&.destroy
  end

  private

  def add_to_master_calendar_events(events, workspace)
    @workspace = workspace
    events_to_be_imports = []
    calendar_services = []

    events.each do |event|
      if event.status == "cancelled"
        cancel_event!(event)
      else
        events_to_be_imports << build_import_event(event)
        calendar_services << build_import_calendar_service(event)
      end
    end
    event_ids = import_events(events_to_be_imports.uniq { |event| [event.fetch(:workspace_id), event.fetch(:i_cal_uid)] })
    calendar_services.each_with_index do |calendar_service, index|
      calendar_service[:event_id] = event_ids[index]["id"]
    end

    import_calendar_services(calendar_services)
  end

  def build_import_event(event)
    all_day = event.start.date.present? && event.end.date.present?
    repeat = "never"
    repeat_until_date = nil
    repeat_except_dates = []

    if event.recurrence.present?
      rrule = serialize_recurrence(event.recurrence)
      repeat = rrule["FREQ"].downcase
      repeat_until_date = rrule["UNTIL"].to_date if rrule["UNTIL"].present?
      repeat_except_dates = rrule["EXDATE"] if rrule["EXDATE"].present?
    end

    {
      name: event.summary,
      description: event.description,
      start_time: all_day ? event.start.date : event.start.date_time,
      end_time: all_day ? (event.end.date - 1.day) : event.end.date_time,
      all_day: all_day,
      created_by_id: current_user.id,
      workspace_id: workspace.id,
      i_cal_uid: event.i_cal_uid,
      source_id: event.id,
      source_type: "google_oauth2",
      event_url: event.html_link,
      repeat: repeat,
      repeat_until_date: repeat_until_date,
      repeat_except_dates: repeat_except_dates,
      etag: JSON.parse(event.etag),
      recurrence: event.recurrence,
      payload: event.to_json
    }
  end

  def build_import_calendar_service(event)
    {
      provider: "google_oauth2",
      name: "Google Calendar",
      i_cal_uid: event.i_cal_uid,
      url: event.html_link,
      import_type: "manual",
      imported_by_id: current_user.id,
      etag: JSON.parse(event.etag),
      payload: event.to_json
    }
  end

  def cancel_event!(event)
    cancelled_event = @workspace.events.find_by(source_id: event.id)
    return if cancelled_event.blank?

    cancelled_event.destroy
  end

  def import_events(events)
    Event.upsert_all(
      events,
      record_timestamps: true,
      unique_by: [:workspace_id, :i_cal_uid],
      returning: %w[id]
    )
  end

  def import_calendar_services(calendar_services)
    CalendarService.upsert_all(
      calendar_services,
      record_timestamps: true,
      unique_by: [:event_id, :i_cal_uid, :provider]
    )
  end
end
