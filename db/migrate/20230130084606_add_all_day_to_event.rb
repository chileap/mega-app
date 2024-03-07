class AddAllDayToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :all_day, :boolean, default: true

    Event.all.each do |event|
      start_time = event.start_time.strftime("%Y-%m-%d %H:%M")
      end_time = event.end_time.strftime("%Y-%m-%d %H:%M")

      beginning_of_day = event.start_time.beginning_of_day.strftime("%Y-%m-%d %H:%M")
      end_of_day = event.end_time.end_of_day.strftime("%Y-%m-%d %H:%M")

      next if start_time == beginning_of_day && end_time == end_of_day
      event.update(all_day: false)
    end
  end
end
