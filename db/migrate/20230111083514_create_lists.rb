class CreateLists < ActiveRecord::Migration[7.0]
  def change
    create_table :lists do |t|
      t.references :account
      t.references :created_by, foreign_key: {to_table: :users}
      t.string :name

      t.boolean :default, default: false
      t.timestamps
    end
  end
end
