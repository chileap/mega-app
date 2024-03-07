class AddIndexToCalendarServices < ActiveRecord::Migration[7.0]
  def change
    add_index :calendar_services, [:event_id, :i_cal_uid, :provider], unique: true
  end
end
