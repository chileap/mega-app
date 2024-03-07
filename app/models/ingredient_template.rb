# == Schema Information
#
# Table name: ingredient_templates
#
#  id               :bigint           not null, primary key
#  notes            :text
#  quantity         :string           not null
#  unit_type        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  grocery_id       :bigint           not null
#  meal_template_id :bigint           not null
#
# Indexes
#
#  index_ingredient_templates_on_grocery_id        (grocery_id)
#  index_ingredient_templates_on_meal_template_id  (meal_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (grocery_id => groceries.id)
#  fk_rails_...  (meal_template_id => meal_templates.id)
#
class IngredientTemplate < ApplicationRecord
  belongs_to :meal_template, counter_cache: true
  belongs_to :grocery
end
