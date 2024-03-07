# == Schema Information
#
# Table name: timeboxings
#
#  id                     :bigint           not null, primary key
#  brain_dump             :text
#  date                   :date             not null
#  notes                  :text
#  timeboxing_items_count :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint           not null
#  workspace_id           :bigint           not null
#
# Indexes
#
#  index_timeboxings_on_date_and_user_id_and_workspace_id  (date,user_id,workspace_id) UNIQUE
#  index_timeboxings_on_user_id                            (user_id)
#  index_timeboxings_on_workspace_id                       (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
FactoryBot.define do
  factory :timeboxing do
    date { Date.today }
    user
    workspace
  end
end
