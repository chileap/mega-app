class Events::UpdateWorkflow < ApplicationWorkflow
  attr_reader :event, :params, :sync_services

  def initialize(event, params)
    @event = event
    @sync_services = params.delete(:sync_services)
    @params = params
  end

  def call
    event.assign_attributes(params)
    time_zone = event.time_zone.present? ? ActiveSupport::TimeZone[event.time_zone] : Time.zone
    if params[:start_time].present?
      event.start_time = "#{params[:start_time]} #{time_zone}".to_datetime.rfc3339
    end
    if params[:end_time].present?
      event.end_time = "#{params[:end_time]} #{time_zone}".to_datetime.rfc3339
    end

    if event.save
      if sync_services.present?
        sync_services.each do |sync_service|
          next if sync_service.blank?

          connected_account = event.workspace.connected_accounts.find_by(provider: sync_service)
          next if connected_account.blank?
          sync_service = "Calendars::Events::#{sync_service.camelize}Service".constantize.new(connected_account)
          sync_service.upsert_event(event)
        end
      end
    end

    event
  end
end
