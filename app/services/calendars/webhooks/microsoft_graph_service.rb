class Calendars::Webhooks::MicrosoftGraphService < Calendars::BaseCalendarService
  WEBHOOK_CALLBACK_URL = "#{Rails.application.credentials.app_url}/webhooks/calendar/outlook_callbacks"

  def sync_calendar_events(webhook, params)
    @webhook = webhook
    resource = params[:value].first
    Rails.logger.info "Syncing event #{resource["resourceData"]["id"]}"
    upsert_webhook(webhook) if webhook_expired?(resource)
    outlook_event = client.get_event(resource["resourceData"]["id"])
    if outlook_event["error"].present? && outlook_event["error"]["code"] == "ResourceNotFound"
      Rails.logger.info "Event not found, skipping"
      return
    end

    case resource["changeType"]
    when "created"
      Rails.logger.info "Event created, creating event in workspace"
      create_master_event(webhook, outlook_event)
    when "updated"
      Rails.logger.info "Event updated, updating event in workspace"
      update_master_event(webhook, outlook_event)
    when "deleted"
      Rails.logger.info "Event deleted, deleting event in workspace"
      delete_master_event(webhook, outlook_event)
    end
  end

  def webhook_expired?(resource)
    resource[:subscriptionExpirationDateTime].to_datetime.to_i * 1000 < Time.now.to_i * 1000
  end

  def upsert_webhook(webhook = nil)
    webhook ||= account.webhook
    if webhook.present?
      update_webhook(webhook)
    else
      create_webhook
    end
  end

  def create_webhook(workspace = nil)
    workspace ||= account.workspace
    user = account.user
    outlook_webhook = client.create_webhook
    master_webhook = account.build_webhook(
      provider: "microsoft_graph",
      resource_id: outlook_webhook["applicationId"],
      resource_uri: outlook_webhook["@odata.context"],
      channel_id: outlook_webhook["id"],
      expiration: outlook_webhook["expirationDateTime"].to_datetime.to_i * 1000,
      kind: outlook_webhook["changeType"],
      created_by: user,
      workspace: workspace,
      callback_url: outlook_webhook["notificationUrl"],
      payload: outlook_webhook
    )
    master_webhook.save!
  end

  def update_webhook(webhook)
    outlook_webhook = client.get_webhook(webhook)
    if outlook_webhook["error"].present? && outlook_webhook["error"]["code"] == "ResourceNotFound"
      Rails.logger.info "Webhook not found, creating new webhook"
      new_outlook_webhook = client.create_webhook
      Rails.logger.info "New webhook created. Updating webhook"
      webhook.update!(
        resource_id: new_outlook_webhook["applicationId"],
        resource_uri: new_outlook_webhook["@odata.context"],
        channel_id: new_outlook_webhook["id"],
        expiration: new_outlook_webhook["expirationDateTime"].to_datetime.to_i * 1000,
        kind: new_outlook_webhook["changeType"],
        callback_url: new_outlook_webhook["notificationUrl"],
        payload: new_outlook_webhook
      )
    elsif outlook_webhook["notificationUrl"] != "#{WEBHOOK_CALLBACK_URL}?webhook_id=#{webhook.channel_id}"
      Rails.logger.info "Webhook is invalid, updating new webhook"
      new_outlook_webhook = client.update_webhook(webhook)

      Rails.logger.info "New webhook updated. Updating webhook"
      webhook.update!(
        resource_id: new_outlook_webhook["applicationId"],
        resource_uri: new_outlook_webhook["@odata.context"],
        channel_id: new_outlook_webhook["id"],
        expiration: new_outlook_webhook["expirationDateTime"].to_datetime.to_i * 1000,
        kind: new_outlook_webhook["changeType"],
        callback_url: new_outlook_webhook["notificationUrl"],
        payload: new_outlook_webhook
      )
    elsif outlook_webhook["error"].blank?
      Rails.logger.info "Webhook is valid, updating webhook"
      new_outlook_webhook = client.update_webhook(webhook)
      Rails.logger.info "Webhook updated. Updating current webhook"

      webhook.update!(
        resource_id: new_outlook_webhook["applicationId"],
        resource_uri: new_outlook_webhook["@odata.context"],
        channel_id: new_outlook_webhook["id"],
        expiration: new_outlook_webhook["expirationDateTime"].to_datetime.to_i * 1000,
        kind: new_outlook_webhook["changeType"],
        callback_url: new_outlook_webhook["notificationUrl"],
        payload: new_outlook_webhook
      )
    else
      Rails.logger.info "Webhook update failed"
      raise "Webhook update failed"
    end
  end

  def delete_webhook(webhook)
    client.delete_webhook(webhook.channel_id)
    webhook.destroy!
  end

  private

  def create_master_event(webhook, outlook_event)
    workspace = webhook.workspace
    calendar_service = workspace.calendar_services.find_by(provider: "microsoft_graph", source_id: outlook_event["id"])

    if calendar_service.present?
      Rails.logger.info "Event already exists, skipping"
      update_master_event(webhook, outlook_event)
      return
    end

    event_start = outlook_event["start"]["dateTime"]
    event_end = outlook_event["end"]["dateTime"]

    if outlook_event["isAllDay"]
      event_start = event_start.beginning_of_day
      event_end = (event_end.to_date - 1.day).end_of_day
    end

    event = workspace.events.create(
      name: outlook_event["subject"],
      description: outlook_event["bodyPreview"],
      start_time: event_start,
      end_time: event_end,
      i_cal_uid: outlook_event["iCalUId"],
      source_type: "microsoft_graph",
      source_id: outlook_event["id"],
      etag: outlook_event["@odata.etag"],
      time_zone: outlook_event["originalStartTimeZone"],
      all_day: outlook_event["isAllDay"],
      event_url: outlook_event["webLink"],
      created_by_id: webhook.created_by_id,
      payload: outlook_event.to_json
    )

    if event.errors.any?
      Rails.logger.info "Event creation failed"
      Rails.logger.info event.errors.full_messages
      return
    end

    event.calendar_services.create!(
      provider: "microsoft_graph",
      i_cal_uid: outlook_event["iCalUId"],
      url: outlook_event["webLink"],
      payload: outlook_event.to_json,
      imported_by: webhook.created_by,
      import_type: "webhook",
      name: "Outlook Calendar",
      source_id: outlook_event["id"],
      etag: outlook_event["@odata.etag"]
    )
  end

  def update_master_event(webhook, outlook_event)
    workspace = webhook.workspace
    calendar_service = workspace.calendar_services.find_by(provider: "microsoft_graph", source_id: outlook_event["id"])
    if calendar_service.present?
      Rails.logger.info "Event found, updating event"
      calendar_service.update!(
        provider: "microsoft_graph",
        i_cal_uid: outlook_event["iCalUId"],
        url: outlook_event["webLink"],
        payload: outlook_event.to_json,
        imported_by: webhook.created_by,
        import_type: "webhook",
        name: "Outlook Calendar",
        source_id: outlook_event["id"],
        etag: outlook_event["@odata.etag"]
      )
    else
      Rails.logger.info "Event not found, creating event"
      create_master_event(webhook, outlook_event)
    end
  end
end
