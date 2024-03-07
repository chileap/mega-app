class Events::CreateWorkflow < ApplicationWorkflow
  attr_reader :params, :sync_services

  def initialize(sync_services, params)
    @params = params
    @sync_services = sync_services
  end

  def call
    if event.save
      if sync_services.present?
        sync_services.each do |sync_service|
          next if sync_service.blank?

          connected_account = event.workspace.connected_accounts.find_by(provider: sync_service)

          next if connected_account.blank?
          sync_service = "Calendars::Events::#{sync_service.camelize}Service".constantize.new(connected_account)
          sync_service.insert_event(event)
        end
      end
    end

    event
  end

  private

  def event
    @event ||= Event.new(params)

    time_zone = @event.time_zone.present? ? ActiveSupport::TimeZone[@event.time_zone] : Time.zone

    @event.start_time = "#{params[:start_time]} #{time_zone}".to_datetime.rfc3339
    @event.end_time = "#{params[:end_time]} #{time_zone}".to_datetime.rfc3339
    @event
  end
end
