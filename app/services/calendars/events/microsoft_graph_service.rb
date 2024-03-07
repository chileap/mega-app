class Calendars::Events::MicrosoftGraphService < Calendars::BaseCalendarService
  attr_reader :current_user, :workspace

  def sync_calendar_events(workspace = nil, current_user = nil)
    @workspace = workspace || account.workspace
    @current_user = current_user || account.user
    fetch_calendar_events(workspace)

    Calendars::Webhooks::MicrosoftGraphService.new(account).upsert_webhook
  end

  def fetch_calendar_events(workspace = nil)
    @workspace = workspace
    client.fetch_calendar_events do |events|
      next if events.blank?
      next if @workspace.blank?

      add_to_master_calendar(events)
    end
  end

  def upsert_event(event)
    if event.calendar_services.find_by(provider: "microsoft_graph").present?
      update_event(event)
    else
      insert_event(event)
    end
  end

  def insert_event(event)
    outlook_event = client.create_event(event)
    calendar_service = CalendarService.find_or_create_by(
      event_id: event.id,
      name: "Microsoft Calendar",
      i_cal_uid: outlook_event["iCalUId"],
      source_id: outlook_event["id"]
    )

    calendar_service.update!(
      provider: "microsoft_graph",
      payload: outlook_event.to_json,
      import_type: "manual",
      imported_by_id: event.created_by_id,
      url: outlook_event["webLink"]
    )
    event
  end

  def update_event(event)
    calendar_service = CalendarService.find_by(event_id: event.id, provider: "microsoft_graph")
    outlook_event = client.update_event(event, calendar_service.source_id)

    calendar_service.update!(
      event_id: event.id,
      name: "Microsoft Calendar",
      i_cal_uid: outlook_event["iCalUId"],
      source_id: outlook_event["id"],
      provider: "microsoft_graph",
      payload: outlook_event.to_json,
      import_type: "manual",
      imported_by_id: event.created_by_id,
      url: outlook_event["webLink"]
    )
    event
  end

  def delete_event(event)
    calendar_service = CalendarService.find_by(event_id: event.id, provider: "microsoft_graph")
    client.delete_event(calendar_service.source_id)
    calendar_service&.destroy
    event
  end

  private

  def add_to_master_calendar(events)
    events_to_be_imports = []
    calendar_services = []

    events.each do |event|
      if event["isCancelled"]
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
    all_day = event["isAllDay"]
    repeat = "never"
    repeat_until_date = nil
    repeat_except_dates = []

    if event["recurrence"].present?
      repeat = event["recurrence"]["pattern"]["type"].downcase
      repeat_until_date = event["recurrence"]["range"]["endDate"].to_date if event["recurrence"]["range"]["endDate"].present?
      repeat_except_dates = event["recurrence"]["range"]["excludeDates"].map(&:to_date) if event["recurrence"]["range"]["excludeDates"].present?
    end

    {
      name: event["subject"],
      description: event["bodyPreview"],
      start_time: event["start"]["dateTime"],
      end_time: all_day ? (event["end"]["dateTime"].to_datetime - 1.day) : event["end"]["dateTime"],
      all_day: all_day,
      repeat: repeat,
      repeat_until_date: repeat_until_date,
      repeat_except_dates: repeat_except_dates,
      workspace_id: workspace.id,
      i_cal_uid: event["iCalUId"],
      source_type: "microsoft_graph",
      source_id: event["id"],
      recurrence: event["recurrence"],
      payload: event,
      created_by_id: current_user.id
    }
  end

  def build_import_calendar_service(event)
    {
      name: "Microsoft Calendar",
      i_cal_uid: event["iCalUId"],
      source_id: event["id"],
      provider: "microsoft_graph",
      payload: event,
      import_type: "manual",
      imported_by_id: current_user.id
    }
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

  def cancel_event!(event)
    cancelled_event = @workspace.events.find_by(source_id: event.id)
    return if cancelled_event.blank?

    cancelled_event.destroy
  end
end
