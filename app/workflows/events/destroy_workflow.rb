class Events::DestroyWorkflow < ApplicationWorkflow
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def call
    if event.destroy
      event.calendar_services.each do |calendar_service|
        connected_account = event.workspace.connected_accounts.find_by(provider: sync_service)
        next if connected_account.blank?
        sync_service = "Calendars::Events::#{connected_account.provider.camelize}Service".constantize.new(connected_account)
        sync_service.delete_event(event)
      end
    end

    event
  end
end
