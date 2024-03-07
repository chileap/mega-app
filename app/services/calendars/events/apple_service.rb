class Calendars::Events::AppleService < Calendars::BaseCalendarService
  def sync_calendar_events(workspace = nil)
    @workspace = workspace || account.workspace

    events = client.fetch_calendar_events
    add_to_calendar(events)
  end

  def upsert_event(event)
    if event.calendar_services.find_by(provider: "apple").present?
      update_event(event)
    else
      insert_event(event)
    end
  end

  def insert_event(event)
    apple_event_url = client.upsert_event(event)
    apple_event = client.get_event(apple_event_url)

    calendar_data = Icalendar::Event.parse(apple_event.calendar_data).first

    calendar_service = CalendarService.find_or_create_by(
      event_id: event.id,
      name: "Apple Calendar",
      i_cal_uid: calendar_data.uid.to_s,
      provider: "apple"
    )

    calendar_service.update!(
      source_id: calendar_data.uid.to_s,
      payload: calendar_data.to_json,
      import_type: "manual",
      url: apple_event_url,
      imported_by_id: event.created_by_id,
      etag: JSON.parse(apple_event.etag)
    )
    event
  end

  def update_event(event)
    apple_event_url = client.update_event(event)
    apple_event = client.get_event(apple_event_url)

    calendar_data = Icalendar::Event.parse(apple_event.calendar_data).first

    calendar_service = CalendarService.find_or_create_by(
      event_id: event.id,
      name: "Apple Calendar",
      i_cal_uid: calendar_data.uid.to_s,
      provider: "apple"
    )

    calendar_service.update!(
      source_id: calendar_data.uid.to_s,
      payload: calendar_data.to_json,
      import_type: "manual",
      url: apple_event_url,
      imported_by_id: event.created_by_id,
      etag: JSON.parse(apple_event.etag)
    )
    event
  end

  def delete_event(event)
    calendar_service = event.calendar_services.find_by(provider: "apple")
    client.delete_event(calendar_service)

    calendar_service.destroy
  end

  private

  def add_to_calendar(events)
    events_to_be_imports = []
    calendar_services = []
    events.each do |event|
      calendar_data = Icalendar::Event.parse(event.calendar_data).first
      if calendar_data.status&.downcase == "cancelled"
        cancel_event!(calendar_data)
      else
        events_to_be_imports << build_import_event(calendar_data).merge(
          etag: JSON.parse(event.etag),
          payload: event.calendar_data,
          event_url: event.url
        )

        calendar_services << build_import_calendar_service(calendar_data).merge(
          payload: event.calendar_data,
          url: event.url,
          etag: JSON.parse(event.etag)
        )
      end
    end

    event_ids = import_events(events_to_be_imports.uniq { |event| [event.fetch(:workspace_id), event.fetch(:i_cal_uid)] })
    calendar_services.each_with_index do |calendar_service, index|
      calendar_service[:event_id] = event_ids[index]["id"]
    end

    import_calendar_services(calendar_services)
  end

  def build_import_event(calendar_data)
    repeat = "never"
    repeat_until_date = nil
    repeat_except_dates = []
    repeat_count = nil
    rrule_payload = {}

    if calendar_data.rrule.present?
      rrule = calendar_data.rrule.first
      repeat = rrule.frequency.downcase
      repeat_until_date = rrule.until&.to_datetime
      repeat_count = rrule.count
      repeat_except_dates = calendar_data.exdate&.map(&:to_datetime)
      rrule_payload = rrule.to_json
    end

    {
      workspace_id: @workspace.id,
      i_cal_uid: calendar_data.uid&.to_s,
      source_type: "apple",
      created_by_id: account.user.id,
      start_time: calendar_data.dtstart&.to_datetime,
      end_time: calendar_data.dtend&.to_datetime,
      time_zone: calendar_data.custom_properties["tzid"]&.first&.to_s,
      name: calendar_data.summary&.to_s,
      description: calendar_data.description&.to_s,
      repeat: repeat,
      repeat_until_date: repeat_until_date,
      repeat_except_dates: repeat_except_dates,
      repeat_count: repeat_count,
      recurrence: rrule_payload
    }
  end

  def build_import_calendar_service(event)
    {
      provider: "apple",
      name: "Apple Calendar",
      i_cal_uid: event.uid&.to_s
    }
  end

  def cancel_event!(calendar_data)
    cancelled_event = workspace.events.where(
      workspace_id: workspace.id,
      i_cal_uid: calendar_data.first.uid.to_s
    ).first
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
