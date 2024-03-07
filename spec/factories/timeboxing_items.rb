# == Schema Information
#
# Table name: timeboxing_items
#
#  id            :bigint           not null, primary key
#  completed_at  :datetime
#  end_time      :datetime
#  name          :string           not null
#  notes         :text
#  priority      :boolean          default(FALSE)
#  start_time    :datetime
#  time_zone     :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  timeboxing_id :bigint           not null
#  user_id       :bigint           not null
#  workspace_id  :bigint           not null
#
# Indexes
#
#  index_timeboxing_items_on_timeboxing_id  (timeboxing_id)
#  index_timeboxing_items_on_user_id        (user_id)
#  index_timeboxing_items_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (timeboxing_id => timeboxings.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
FactoryBot.define do
  factory :timeboxing_item do
    name { "MyString" }
    start_time { Time.current }
    end_time { 1.hour.from_now }
    time_zone { Time.zone.name }
    user
    workspace
    timeboxing
  end
end
