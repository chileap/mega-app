class Calendars::Webhooks::GoogleOauth2Service < Calendars::BaseCalendarService
  attr_reader :current_user, :workspace
  WEBHOOK_CALLBACK_URL = "#{Rails.application.credentials.app_url}/webhooks/calendar/google_callbacks"

  def sync_calendar_events(webhook)
    @workspace = webhook.workspace
    @current_user = webhook.created_by

    fetch_calendar_events(webhook)
    update_webhook(webhook) if webhook.expired?
    webhook.update!(next_sync_token: client.sync_token)
  end

  def upsert_webhook
    if account.webhook.present? && account.webhook.expired?
      update_webhook(account.webhook)
    elsif account.webhook.blank?
      create_webhook
    elsif account.webhook.callback_url != "#{WEBHOOK_CALLBACK_URL}?webhook_id=#{account.webhook.channel_id}"
      delete_webhook(account.webhook)
      create_webhook
    end
  end

  def delete_webhook(webhook)
    client.delete_webhook(webhook)
    webhook.destroy!
  rescue
    webhook.destroy!
  end

  def fetch_calendar_events(webhook)
    client.fetch_calendar_events_with_webhook(webhook) do |events|
      next if events.blank?
      add_to_master_calendar_events(events)
    end
  end

  def create_webhook(workspace = nil)
    workspace = account.workspace if workspace.nil?
    webhook = client.create_webhook
    master_webhook = account.build_webhook(
      provider: "google_oauth2",
      resource_id: webhook.resource_id,
      resource_uri: webhook.resource_uri,
      channel_id: webhook.id,
      expiration: webhook.expiration,
      kind: webhook.kind,
      next_sync_token: client.sync_token,
      created_by: account.user,
      workspace: workspace,
      callback_url: WEBHOOK_CALLBACK_URL,
      payload: webhook.to_json
    )
    master_webhook.save!
  end

  def update_webhook(webhook)
    google_webhook = client.update_webhook(webhook)
    webhook.update!(
      resource_id: google_webhook.resource_id,
      resource_uri: google_webhook.resource_uri,
      channel_id: google_webhook.id,
      expiration: google_webhook.expiration,
      kind: google_webhook.kind,
      next_sync_token: client.sync_token,
      payload: google_webhook.to_json
    )
  end

  private

  def add_to_master_calendar_events(events)
    @workspace = workspace
    events_to_be_imports = []
    calendar_services = []

    events.each do |event|
      existed_service = workspace.calendar_services.find_by(i_cal_uid: event.i_cal_uid, provider: "google_oauth2")

      if event.status == "cancelled"
        cancel_event!(event)
      elsif existed_service.present?
        events_to_be_imports << build_import_existed_event(event, existed_service)
        calendar_services << build_import_existed_calendar_service(event, existed_service)
      else
        events_to_be_imports << build_import_event(event)
        calendar_services << build_import_calendar_service(event)
      end
    end

    if events_to_be_imports.present?
      event_ids = import_events(events_to_be_imports.uniq { |event| [event.fetch(:workspace_id), event.fetch(:i_cal_uid)] })
      calendar_services.each_with_index do |calendar_service, index|
        calendar_service[:event_id] = event_ids[index]["id"]
      end

      import_calendar_services(calendar_services)
    end
  end

  def build_import_existed_event(event, existed_service)
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
      i_cal_uid: existed_service.event.i_cal_uid.present? ? existed_service.event.i_cal_uid : event.i_cal_uid,
      source_id: existed_service.event.source_id || event.id,
      source_type: existed_service.event.source_type,
      event_url: existed_service.event.event_url.present? ? existed_service.event.event_url : event.html_link,
      repeat: repeat,
      repeat_until_date: repeat_until_date,
      repeat_except_dates: repeat_except_dates,
      etag: existed_service.event.etag.present? ? existed_service.event.etag : JSON.parse(event.etag),
      recurrence: event.recurrence,
      payload: existed_service.event.payload.present? ? existed_service.event.payload : event.to_json
    }
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

  def build_import_existed_calendar_service(event, existed_service)
    {
      provider: "google_oauth2",
      name: "Google Calendar",
      source_id: event.id,
      i_cal_uid: event.i_cal_uid,
      url: event.html_link,
      import_type: existed_service.import_type,
      imported_by_id: existed_service.imported_by_id,
      etag: JSON.parse(event.etag),
      payload: event.to_json
    }
  end

  def build_import_calendar_service(event)
    {
      provider: "google_oauth2",
      name: "Google Calendar",
      source_id: event.id,
      i_cal_uid: event.i_cal_uid,
      url: event.html_link,
      import_type: "webhook",
      imported_by_id: current_user.id,
      etag: JSON.parse(event.etag),
      payload: event.to_json
    }
  end

  def cancel_event!(event)
    if event.recurring_event_id.present?
      google_event = client.fetch_event(event.recurring_event_id)
      cancelled_event = workspace.events.find_by(source_id: event.recurring_event_id)
      calendar_service = workspace.calendar_services.find_by(
        provider: "google_oauth2",
        source_id: google_event.id
      )

      if cancelled_event.blank? && calendar_service.present?
        cancelled_event = calendar_service.event
      end

      return if cancelled_event.blank?

      except_dates = if cancelled_event.all_day
        cancelled_event.repeat_except_dates + [event.original_start_time.date.to_date]
      else
        cancelled_event.repeat_except_dates + [event.original_start_time.date_time.to_datetime]
      end

      cancelled_event.repeat_except_dates = except_dates
      cancelled_event.payload = google_event.to_json if cancelled_event.payload.blank?
      cancelled_event.save!

      calendar_service.update!(
        i_cal_uid: google_event.i_cal_uid,
        url: google_event.html_link,
        etag: JSON.parse(google_event.etag),
        payload: google_event.to_json,
        event_id: cancelled_event.id
      )
    else
      cancelled_event = @workspace.events.find_by(source_id: event.id)
      return if cancelled_event.blank?

      cancelled_event.destroy
    end
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

  def serialize_recurrence(recurrence)
    return if recurrence.blank?
    rrule_hash = {}

    recurrence.each do |rule|
      if rule.include?("EXDATE")
        exdate = rule.split("=").last.split(",").map do |date|
          date.to_date.strftime("%Y-%m-%d")
        end
        rrule_hash["EXDATE"] = exdate
        next
      end

      new_rule = rule.split(";")
      new_rule.each do |rule|
        key = rule.split("=").first.split("RRULE:").last

        rrule_hash[key] = rule.split("=").last
      end
    end

    rrule_hash
  end
end
