class CreateGoals < ActiveRecord::Migration[7.0]
  def change
    create_table :goals do |t|
      t.string :type
      t.integer :value
      t.text :description
      t.datetime :start_date
      t.datetime :end_date

      t.datetime :completed_at
      t.references :created_by, null: false, foreign_key: {to_table: :users}
      t.references :workspace, null: false, foreign_key: true
      t.timestamps
    end
  end
end
