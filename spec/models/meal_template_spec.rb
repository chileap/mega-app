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
require "rails_helper"

RSpec.describe MealTemplate, type: :model do
  describe "associations" do
    it { should have_many(:ingredient_templates) }
    it { should have_many(:meals) }
    it { should have_many(:instruction_template_steps) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "default scope" do
    it "should order by name" do
      meal_template1 = create(:meal_template, name: "A")
      meal_template2 = create(:meal_template, name: "B")
      meal_template3 = create(:meal_template, name: "C")
      expect(MealTemplate.all).to eq([meal_template1, meal_template2, meal_template3])
    end
  end
end
