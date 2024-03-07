class CreateMealTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :meal_templates do |t|
      t.string :name, null: false
      t.integer :serving_for, default: 2
      t.integer :ingredient_templates_count, default: 0
      t.text :description
      t.integer :prep_time
      t.integer :cook_time
      t.integer :total_time

      t.text :payload
      t.timestamps
    end
  end
end
