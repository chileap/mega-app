class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.references :account, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: {to_table: :users}
      t.string :name
      t.text :description
      t.string :time_zone
      t.datetime :start_time
      t.datetime :end_time
      t.string :event_type
      t.string :source_type
      t.string :source_id

      t.timestamps
    end
  end
end
