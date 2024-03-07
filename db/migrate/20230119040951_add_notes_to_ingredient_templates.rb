class AddNotesToIngredientTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :ingredient_templates, :notes, :text
  end
end
