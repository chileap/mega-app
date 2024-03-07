class RemoveNullFalseInUnitTypeForIngredientAndIngredientTemplate < ActiveRecord::Migration[7.0]
  def change
    change_column_null :ingredients, :unit_type, true
    change_column_null :ingredient_templates, :unit_type, true
  end
end
