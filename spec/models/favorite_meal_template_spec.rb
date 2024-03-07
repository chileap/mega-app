# == Schema Information
#
# Table name: favorite_meal_templates
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  meal_template_id :bigint           not null
#  user_id          :bigint           not null
#  workspace_id     :bigint           not null
#
# Indexes
#
#  index_fav_meals_on_user_id_and_meal_temp_id_and_workspace_id  (user_id,meal_template_id,workspace_id) UNIQUE
#  index_favorite_meal_templates_on_meal_template_id             (meal_template_id)
#  index_favorite_meal_templates_on_user_id                      (user_id)
#  index_favorite_meal_templates_on_workspace_id                 (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (meal_template_id => meal_templates.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
require "rails_helper"

RSpec.describe FavoriteMealTemplate, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:meal_template) }
    it { should belong_to(:workspace) }
  end

  describe "validations" do
    let!(:user) { create(:user) }
    let!(:workspace) { create(:workspace) }
    let!(:workspace_user) { create(:workspace_user, user: user, workspace: workspace) }
    let!(:meal_template) { create(:meal_template) }
    let!(:favorite_meal_template) { create(:favorite_meal_template, user: user, meal_template: meal_template, workspace: workspace) }

    it { should validate_uniqueness_of(:user_id).scoped_to([:meal_template_id, :workspace_id]) }
  end
end
