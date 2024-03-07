require "google/apis/calendar_v3"
require "google/api_client/client_secrets"

class GoogleOauth2Client
  TIME_MIN = 3.months.ago.rfc3339
  GOOGLE_CLIENT_ID = Rails.application.credentials.omniauth.google_oauth2&.public_key
  GOOGLE_CLIENT_SECRET = Rails.application.credentials.omniauth.google_oauth2&.private_key
  WEBHOOK_CALLBACK_URL = "#{Rails.application.credentials.app_url}/webhooks/calendar/google_callbacks"
  OMNIAUTH_CALLBACK_URL = "#{Rails.application.credentials.app_url}/oauth2/google_oauth2/callback"

  attr_reader :account, :sync_token

  def initialize(account)
    @account = account
    @sync_token = nil
  end

  def client
    @client ||= begin
      client = Google::Apis::CalendarV3::CalendarService.new
      client.authorization = authorization
      client
    end
  end

  def fetch_calendar_events
    events_list = fetch_events
    loop do
      yield events_list.items
      break if events_list.next_page_token.blank?
      events_list = fetch_next_page_events(events_list.next_page_token)
    end
    @sync_token = events_list.next_sync_token
  end

  def fetch_calendar_events_with_webhook(webhook)
    events_list = fetch_events_with_webhook(webhook)
    loop do
      yield events_list.items
      break if events_list.next_page_token.blank?
      events_list = fetch_next_page_events(events_list.next_page_token)
    end
    @sync_token = events_list.next_sync_token
  end

  def create_webhook
    webhook_uid = SecureRandom.uuid
    webhook_channel = Google::Apis::CalendarV3::Channel.new(
      address: "#{WEBHOOK_CALLBACK_URL}?webhook_id=#{webhook_uid}",
      id: webhook_uid,
      type: "web_hook"
    )
    client.watch_event("primary", webhook_channel)
  end

  def update_webhook(webhook)
    webhook_channel = Google::Apis::CalendarV3::Channel.new(
      address: "#{WEBHOOK_CALLBACK_URL}?webhook_id=#{webhook.channel_id}",
      id: webhook.channel_id,
      resource_id: webhook.resource_id,
      type: "web_hook"
    )
    client.watch_event("primary", webhook_channel)
  end

  def delete_webhook(webhook)
    webhook_channel = Google::Apis::CalendarV3::Channel.new(
      address: WEBHOOK_CALLBACK_URL,
      id: webhook.channel_id,
      resource_id: webhook.resource_id,
      type: "web_hook"
    )

    client.stop_channel(webhook_channel)
  end

  def fetch_event(event_id)
    client.get_event("primary", event_id)
  end

  def insert_event(event)
    google_event = Google::Apis::CalendarV3::Event.new(**serializer_event(event))
    client.insert_event("primary", google_event)
  end

  def update_event(event)
    google_service = event.calendar_services.find_by(provider: "google_oauth2")
    source_id = google_service.source_id

    if source_id.blank?
      payload = JSON.parse(google_service.payload)
      source_id = payload["id"]
    end

    google_event = Google::Apis::CalendarV3::Event.new(**serializer_event(event))
    client.update_event("primary", source_id, google_event)
  end

  def delete_event(event)
    google_service = event.calendar_services.find_by(provider: "google_oauth2")
    source_id = google_service.source_id

    if source_id.blank?
      payload = JSON.parse(google_service.payload)
      source_id = payload["id"]
    end

    client.delete_event("primary", source_id)
  end

  private

  def serializer_event(event)
    event_start = {
      date_time: "#{event.start_time.strftime("%Y-%m-%d %H:%M:%S")} #{ActiveSupport::TimeZone[event.time_zone]}".to_datetime.rfc3339,
      time_zone: event.time_zone
    }

    event_end = {
      date_time: "#{event.end_time.strftime("%Y-%m-%d %H:%M:%S")} #{ActiveSupport::TimeZone[event.time_zone]}".to_datetime.rfc3339,
      time_zone: event.time_zone
    }

    if event.all_day
      event_start = {
        date: event.start_time.strftime("%Y-%m-%d"),
        time_zone: event.time_zone
      }

      event_end = {
        date: event.end_time.strftime("%Y-%m-%d"),
        time_zone: event.time_zone
      }
    end

    {
      recurrence: event.google_recurrence,
      summary: event.name,
      description: event.description,
      start: event_start,
      end: event_end,
      primary: true
    }
  end

  def authorization
    @authorization ||= begin
      authorization = Google::Auth::UserRefreshCredentials.new(
        client_id: GOOGLE_CLIENT_ID,
        client_secret: GOOGLE_CLIENT_SECRET,
        scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
        redirect_uri: OMNIAUTH_CALLBACK_URL
      )
      authorization.update!(
        access_token: account.access_token,
        refresh_token: account.refresh_token,
        expires_at: account.expires_at
      )
      authorization
    end
  end

  def fetch_next_page_events(next_page_token)
    client.list_events(
      "primary",
      max_results: 50,
      page_token: next_page_token
    )
  end

  def fetch_events_with_webhook(webhook)
    if webhook.next_sync_token.blank?
      client.list_events(
        "primary",
        max_results: 50,
        time_min: TIME_MIN
      )
    else
      client.list_events(
        "primary",
        max_results: 50,
        sync_token: webhook.next_sync_token
      )
    end
  end

  def fetch_events
    client.list_events(
      "primary",
      time_min: TIME_MIN,
      max_results: 50
    )
  end
end
