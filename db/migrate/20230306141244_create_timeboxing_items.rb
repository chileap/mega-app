class CreateTimeboxingItems < ActiveRecord::Migration[7.0]
  def change
    create_table :timeboxing_items do |t|
      t.string :name, null: false
      t.text :notes
      t.boolean :priority, default: false
      t.datetime :completed_at
      t.datetime :start_time
      t.datetime :end_time

      t.references :user, null: false, foreign_key: true
      t.references :workspace, null: false, foreign_key: true
      t.references :timeboxing, null: false, foreign_key: true
      t.timestamps
    end
  end
end
