# == Schema Information
#
# Table name: groceries
#
#  id         :bigint           not null, primary key
#  barcode    :string
#  brand_name :string
#  image_data :text
#  image_url  :string
#  name       :string
#  notes      :text
#  payload    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Grocery, type: :model do
  describe "associations" do
    it { should have_many(:grocery_category_tags).dependent(:destroy) }
    it { should have_many(:grocery_categories).through(:grocery_category_tags) }
    it { should have_many(:ingredients).dependent(:destroy) }
    it { should have_many(:meals).through(:ingredients) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end
end
