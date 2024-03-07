class AddSourceIdToCalendarServices < ActiveRecord::Migration[7.0]
  def up
    add_column :calendar_services, :source_id, :string

    CalendarService.all.find_each do |calendar_service|
      payload = calendar_service.payload
      if calendar_service.provider != "microsoft_graph"
        payload = JSON.parse(payload)
      end
      calendar_service.update!(source_id: payload["id"])
    end
  end

  def down
    remove_column :calendar_services, :source_id
  end
end
