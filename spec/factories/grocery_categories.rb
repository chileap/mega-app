# == Schema Information
#
# Table name: grocery_categories
#
#  id         :bigint           not null, primary key
#  name       :string
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_grocery_categories_on_slug  (slug) UNIQUE
#
FactoryBot.define do
  factory :grocery_category do
    name { "Other" }
  end
end
