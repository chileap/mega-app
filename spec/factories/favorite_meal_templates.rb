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
FactoryBot.define do
  factory :favorite_meal_template do
    user
    meal_template
    workspace
  end
end
