class CreateFavoriteMealTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :favorite_meal_templates do |t|
      t.references :user, null: false, foreign_key: true
      t.references :meal_template, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true

      t.index [:user_id, :meal_template_id, :account_id], unique: true, name: "index_favorite_meals_on_user_id_and_meal_temp_id_and_account_id"
      t.timestamps
    end
  end
end
