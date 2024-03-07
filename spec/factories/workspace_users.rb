# == Schema Information
#
# Table name: workspace_users
#
#  id           :bigint           not null, primary key
#  roles        :jsonb            not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint
#  workspace_id :bigint
#
# Indexes
#
#  index_workspace_users_on_user_id       (user_id)
#  index_workspace_users_on_workspace_id  (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
FactoryBot.define do
  factory :workspace_user do
    workspace
    user
  end
end
