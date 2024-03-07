class CreateHabits < ActiveRecord::Migration[7.0]
  def change
    create_table :habits do |t|
      t.string :type
      t.integer :value
      t.datetime :time

      t.references :goal, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: {to_table: :users}
      t.references :workspace, null: false, foreign_key: true
      t.timestamps
    end
  end
end
