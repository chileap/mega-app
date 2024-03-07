class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.references :account, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: {to_table: :users}
      t.string :name, null: false
      t.datetime :completed_at

      t.timestamps
    end
  end
end
