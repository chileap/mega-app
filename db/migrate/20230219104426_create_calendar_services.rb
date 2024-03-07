class CreateCalendarServices < ActiveRecord::Migration[7.0]
  def change
    create_table :calendar_services do |t|
      t.references :event, null: false, foreign_key: true

      t.string :name, null: false
      t.string :i_cal_uid, null: false
      t.string :provider, null: false
      t.string :url
      t.text :payload

      t.timestamps
    end
  end
end
