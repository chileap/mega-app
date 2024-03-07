class CreateIngredients < ActiveRecord::Migration[7.0]
  def change
    create_table :ingredients do |t|
      t.references :grocery, null: false, foreign_key: true
      t.references :meal, null: false, foreign_key: true

      t.string :unit_type
      t.string :quantity
      t.string :notes

      t.datetime :purchased_at
      t.timestamps
    end
  end
end
