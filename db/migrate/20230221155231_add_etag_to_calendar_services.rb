class AddEtagToCalendarServices < ActiveRecord::Migration[7.0]
  def change
    add_column :calendar_services, :etag, :string
  end
end
