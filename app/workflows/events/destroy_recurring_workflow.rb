class Events::DestroyRecurringWorkflow < ApplicationWorkflow
  attr_reader :event, :params, :destroy_method

  def initialize(options)
    @event = options[:event]
    @params = options[:params]

    @destroy_method = params[:destroy_method]
  end

  def call
    case destroy_method
    when "this-event"
      event.update(repeat_except_dates: event.repeat_except_dates + [params[:start_date].to_datetime.rfc3339])
      push_to_connected_calendar("upsert_event")
    when "this-and-following-events"
      event.update(repeat_until_date: params[:start_date].to_datetime.rfc3339)
      push_to_connected_calendar("upsert_event")
    else
      event.destroy
      push_to_connected_calendar("delete_event") if event.source_id.present?
    end

    event
  end

  def push_to_connected_calendar(action)
    User::ConnectedAccount.provider_names.keys.each do |provider|
      connected_account = event.created_by.connected_accounts.for_omniauth(provider)
      next if connected_account.blank?
      client = "#{User::ConnectedAccount.provider_names[provider]}ApiClient".constantize.new(connected_account)
      resp = client.send(action, event)
      syn_with_google_provider(resp) if provider == "google_oauth2" && action != "delete_event"
    end
  rescue => err
    puts err.message
  end

  def syn_with_google_provider(resp)
    event.update!(
      i_cal_uid: resp.i_cal_uid,
      event_type: resp.kind,
      status: resp.status,
      source_id: resp.id,
      payload: resp.to_json
    )
  end
end
