class MicrosoftGraphClient
  TIME_MIN = 3.months.ago
  TIME_MAX = 3.months.from_now
  GRAPH_HOST = "https://graph.microsoft.com"
  WEBHOOK_CALLBACK_URL = "#{Rails.application.credentials.app_url}/webhooks/calendar/outlook_callbacks"

  attr_reader :account

  def initialize(account)
    @account = account
  end

  def request
    @request ||= Faraday.new(
      url: GRAPH_HOST,
      headers: {
        Authorization: "Bearer #{account.token}",
        "Content-Type": "application/json",
        Accept: "application/json"
      }
    ) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      faraday.response :raise_error
    end
  end

  def fetch_calendar_events(start_datetime = TIME_MIN, timezone = "UTC")
    events_list = get_events(start_datetime, timezone)

    loop do
      yield events_list["value"]
      break if events_list["@odata.nextLink"].blank?

      events_list = get_events_with_next_link(events_list["@odata.nextLink"])
    end
  end

  def get_events_with_next_link(next_link)
    response = request.get(next_link)
    JSON.parse(response.body)
  end

  def get_events(start_datetime, timezone = "UTC")
    response = request.get("/v1.0/me/events") do |req|
      req.headers["Prefer"] = "outlook.timezone=\"#{timezone}\""
      req.params["startDateTime"] = start_datetime.iso8601
      req.params["$select"] = "subject,bodyPreview,organizer,webLink,start,end,originalStartTimeZone,recurrence,isAllDay,isCancelled,attendees,iCalUId"
      req.params["$orderby"] = "start/dateTime"
      req.params["$top"] = 50
      req.params["$count"] = "true"
      req.params["$format"] = "json"
    end

    JSON.parse(response.body)
  end

  def get_event(event_id)
    response = request.get("/v1.0/me/events/#{event_id}")
    JSON.parse(response.body)
  end

  def create_event(event)
    response = request.post("/v1.0/me/events", event_payload(event), "Content-Type": "application/json")
    JSON.parse(response.body)
  rescue Faraday::ClientError => e
    Rails.logger.error("Error creating event: #{e.message}")
  end

  def update_event(event, source_id)
    response = request.patch("/v1.0/me/events/#{source_id}", event_payload(event), "Content-Type": "application/json")
    JSON.parse(response.body)
  rescue Faraday::ClientError => e
    Rails.logger.error("Error creating event: #{e.message}")
  end

  def list_webhooks
    response = request.get("/v1.0/subscriptions")
    JSON.parse(response.body)
  end

  def get_webhook(webhook)
    response = request.get("/v1.0/subscriptions/#{webhook.channel_id}")
    JSON.parse(response.body)
  end

  def create_webhook
    payload = {
      "changeType" => "created,updated,deleted",
      "notificationUrl" => WEBHOOK_CALLBACK_URL,
      "resource" => "/me/events",
      "expirationDateTime" => 2.days.from_now.iso8601,
      "clientState" => "secretClientValue",
      "notificationContentType" => "application/json"
    }.to_json

    response = request.post("/v1.0/subscriptions", payload, "Content-Type" => "application/json")
    JSON.parse(response.body)
  rescue Faraday::ClientError => e
    Rails.logger.error("Error creating webhook: #{e.message}")
  end

  def update_webhook(webhook, expiration_datetime = 2.days.from_now.iso8601)
    payload = {
      "expirationDateTime" => expiration_datetime,
      "notificationUrl" => "#{WEBHOOK_CALLBACK_URL}?webhook_id=#{webhook.channel_id}"
    }.to_json

    response = request.patch("v1.0/subscriptions/#{webhook.channel_id}", payload, "Content-Type" => "application/json")
    JSON.parse(response.body)
  rescue Faraday::ClientError => e
    Rails.logger.error("Error updating webhook: #{e.message}")
  end

  def delete_event(event_id)
    request.delete("/v1.0/me/events/#{event_id}")

    true
  rescue Faraday::ClientError => e
    Rails.logger.error("Error deleting event: #{e.message}")
  end

  def delete_webhook(webhook_id)
    request.delete("/v1.0/subscriptions/#{webhook_id}")

    true
  rescue Faraday::ClientError => e
    Rails.logger.error("Error deleting webhook: #{e.message}")
  end

  def get_iana_from_windows(windows_tz_name)
    iana = Constants::TIME_ZONE_MAP[windows_tz_name]
    # If no mapping found, assume the supplied
    # value was already an IANA identifier
    iana || windows_tz_name
  end

  def get_windows_from_iana(iana_tz_name)
    windows = Constants::TIME_ZONE_MAP.invert[iana_tz_name]
    # If no mapping found, assume the supplied
    # value was already a Windows identifier
    windows || iana_tz_name
  end

  private

  def success_response?(response)
    response.code == 200 || response.code == 201 || response.code == 204
  end

  def event_payload(event)
    time_zone = event.time_zone
    time_zone = "Asia/Bangkok" if time_zone == "Asia/Jakarta"

    event_start = event.start_time.in_time_zone(time_zone).iso8601
    event_end = event.end_time.in_time_zone(time_zone).iso8601

    if event.all_day
      event_start = event.start_time.in_time_zone(time_zone).to_date
      event_end = event.end_time.in_time_zone(time_zone).to_date + 1.day
    end

    {
      "subject" => event.name,
      "body" => {
        "contentType" => "HTML",
        "content" => event.description
      },
      "start" => {
        "dateTime" => event_start,
        "timeZone" => get_windows_from_iana(time_zone)
      },
      "end" => {
        "dateTime" => event_end,
        "timeZone" => get_windows_from_iana(time_zone)
      },
      "isAllDay" => event.all_day
    }.to_json
  end
end
