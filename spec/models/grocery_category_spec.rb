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
require "rails_helper"

RSpec.describe GroceryCategory, type: :model do
  describe "associations" do
    it { should have_many(:grocery_category_tags).dependent(:destroy) }
    it { should have_many(:groceries).through(:grocery_category_tags) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end
end
