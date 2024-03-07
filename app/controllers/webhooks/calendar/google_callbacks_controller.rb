class Webhooks::Calendar::GoogleCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    if google_header_env[:resource_state] != "sync"
      webhook = Webhook.find_by(channel_id: google_header_env[:channel_id])
      if webhook.blank?
        render json: {status: "error", message: "Webhook not found"}
        return
      else
        webhook_service.new(webhook.connected_account).sync_calendar_events(webhook)
      end
    end
    render json: {status: "success"}
  end

  private

  def webhook_service
    Calendars::Webhooks::GoogleOauth2Service
  end

  def google_header_env
    expiration = request.env["HTTP_X_GOOG_CHANNEL_EXPIRATION"].to_datetime.to_i * 1000
    {
      expiration: expiration,
      channel_id: request.env["HTTP_X_GOOG_CHANNEL_ID"],
      message_number: request.env["HTTP_X_GOOG_MESSAGE_NUMBER"],
      resource_id: request.env["HTTP_X_GOOG_RESOURCE_ID"],
      resource_state: request.env["HTTP_X_GOOG_RESOURCE_STATE"],
      resource_uri: request.env["HTTP_X_GOOG_RESOURCE_URI"]
    }
  end
end
