class CreateGroceries < ActiveRecord::Migration[7.0]
  def change
    create_table :groceries do |t|
      t.string :name
      t.text :image_data
      t.text :notes

      t.references :grocery_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
