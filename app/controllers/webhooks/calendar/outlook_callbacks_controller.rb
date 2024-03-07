class Webhooks::Calendar::OutlookCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    if params[:validationToken].present?
      render inline: params[:validationToken]
    else
      webhook_payload = params["value"].first
      webhook = Webhook.find_by(channel_id: webhook_payload[:subscriptionId])

      if webhook.present?
        webhook_service.new(webhook.connected_account).sync_calendar_events(webhook, params)
        render json: {status: "success"}
      else
        render json: {status: "cannot find webhook"}, status: :not_found
      end
    end
  end

  private

  def webhook_service
    Calendars::Webhooks::MicrosoftGraphService
  end
end
