class AddImportTypeToCalendarService < ActiveRecord::Migration[7.0]
  def change
    add_column :calendar_services, :import_type, :string
    add_reference :calendar_services, :imported_by, foreign_key: {to_table: :users}

    CalendarService.update_all(import_type: :manual)
    CalendarService.all.each do |calendar_service|
      if calendar_service.provider.blank?
        provider_by_name = case calendar_service.name
        when /Google/
          :google_oauth2
        when /Microsoft/
          :microsoft_graph
        when /Apple/
          :apple
        when /Yahoo/
          :yahoo
        end

        existed_calendar_service = CalendarService.find_by(provider: provider_by_name, i_cal_uid: calendar_service.i_cal_uid, event: calendar_service.event)
        if existed_calendar_service.present?
          calendar_service.destroy
        else
          calendar_service.update!(provider: provider_by_name, imported_by: calendar_service.event.created_by)
        end
      else
        calendar_service.update!(imported_by: calendar_service.event.created_by)
      end
    end

    change_column_null :calendar_services, :import_type, false
    change_column_null :calendar_services, :imported_by_id, false
  end
end
