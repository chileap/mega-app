class CreateTimeboxings < ActiveRecord::Migration[7.0]
  def change
    create_table :timeboxings do |t|
      t.date :date, null: false
      t.text :brain_dump
      t.text :priority_task_ids, array: true, default: []

      t.references :workspace, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.index [:date, :user_id, :workspace_id], unique: true
      t.timestamps
    end
  end
end
