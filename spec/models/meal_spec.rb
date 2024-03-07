# == Schema Information
#
# Table name: meals
#
#  id                :bigint           not null, primary key
#  bookmark          :boolean          default(FALSE)
#  completed_at      :datetime
#  cook_time         :integer
#  description       :text
#  ingredients_count :integer          default(0)
#  name              :string           not null
#  prep_time         :integer
#  serving_for       :integer          default(2)
#  total_time        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by_id     :bigint           not null
#  meal_template_id  :bigint
#  workspace_id      :bigint           not null
#
# Indexes
#
#  index_meals_on_created_by_id     (created_by_id)
#  index_meals_on_meal_template_id  (meal_template_id)
#  index_meals_on_workspace_id      (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (meal_template_id => meal_templates.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
require "rails_helper"

RSpec.describe Meal, type: :model do
  describe "associations" do
    it { should belong_to(:workspace) }
    it { should belong_to(:created_by).class_name("User") }
  end
  describe "validations" do
    it { should validate_presence_of(:name) }
  end
end
