class AddTimeZoneToTimeboxingItems < ActiveRecord::Migration[7.0]
  def change
    add_column :timeboxing_items, :time_zone, :string
  end
end
