# == Schema Information
#
# Table name: meal_templates
#
#  id                         :bigint           not null, primary key
#  cook_time                  :integer
#  description                :text
#  ingredient_templates_count :integer          default(0)
#  meals_count                :integer          default(0)
#  name                       :string           not null
#  payload                    :text
#  prep_time                  :integer
#  serving_for                :integer          default(2)
#  total_time                 :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
FactoryBot.define do
  factory :meal_template do
    name { "MyString" }
    description { "MyText" }
    serving_for { 1 }
    prep_time { 1 }
    cook_time { 1 }
    total_time { 1 }

    trait :with_ingredients do
      after(:create) do |meal_template|
        grocery_category = GroceryCategory.first || create(:grocery_category)
        3.times do |t|
          grocery = create(:grocery, name: "grocery #{t}", grocery_categories: [grocery_category])
          create(:ingredient_template, grocery: grocery, meal_template: meal_template)
        end
      end
    end
  end
end
