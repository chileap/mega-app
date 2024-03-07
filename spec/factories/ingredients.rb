# == Schema Information
#
# Table name: ingredients
#
#  id           :bigint           not null, primary key
#  notes        :string
#  purchased_at :datetime
#  quantity     :string
#  unit_type    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  grocery_id   :bigint           not null
#  meal_id      :bigint           not null
#
# Indexes
#
#  index_ingredients_on_grocery_id  (grocery_id)
#  index_ingredients_on_meal_id     (meal_id)
#
# Foreign Keys
#
#  fk_rails_...  (grocery_id => groceries.id)
#  fk_rails_...  (meal_id => meals.id)
#
FactoryBot.define do
  factory :ingredient do
    grocery
    meal
    unit_type { "MyString" }
    quantity { "MyString" }
    note { "MyString" }
  end
end
