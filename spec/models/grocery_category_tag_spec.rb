# == Schema Information
#
# Table name: grocery_category_tags
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  grocery_category_id :bigint           not null
#  grocery_id          :bigint           not null
#
# Indexes
#
#  index_grocery_category_tags_on_grocery_category_id  (grocery_category_id)
#  index_grocery_category_tags_on_grocery_id           (grocery_id)
#
# Foreign Keys
#
#  fk_rails_...  (grocery_category_id => grocery_categories.id)
#  fk_rails_...  (grocery_id => groceries.id)
#
require "rails_helper"

RSpec.describe GroceryCategoryTag, type: :model do
  describe "associations" do
    it { should belong_to(:grocery) }
    it { should belong_to(:grocery_category) }
  end
end
