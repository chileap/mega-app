class MigrateEventSourceToCalendarService < ActiveRecord::Migration[7.0]
  def change
    CalendarService.transaction do
      Event.find_each do |event|
        next if event.source_type == "default"
        source_type = event.source_type
        source_type = "google" if source_type == "gmail"

        CalendarService.find_or_create_by(
          event: event,
          name: source_type.capitalize,
          i_cal_uid: event.i_cal_uid,
          provider: source_type,
          url: event.event_url
        )

        event.update_columns(source_type: "google") if event.source_type == "gmail"
      end
    end
  end
end
