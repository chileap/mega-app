class CreateGoalTrackers < ActiveRecord::Migration[7.0]
  def change
    create_table :goal_trackers do |t|
      t.references :habit, null: false, foreign_key: true
      t.references :tracked_by, null: false, foreign_key: {to_table: :users}

      t.string :value
      t.text :image_data
      t.timestamps
    end
  end
end
