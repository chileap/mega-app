# == Schema Information
#
# Table name: events
#
#  id                  :bigint           not null, primary key
#  all_day             :boolean          default(TRUE)
#  description         :text
#  end_time            :datetime
#  etag                :string
#  event_type          :string
#  event_url           :string
#  i_cal_uid           :string
#  name                :string
#  payload             :text
#  recurrence          :text
#  repeat              :string           default("never")
#  repeat_count        :integer
#  repeat_except_dates :jsonb
#  repeat_until_date   :datetime
#  source_type         :string           default("default")
#  start_time          :datetime
#  status              :string
#  time_zone           :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  created_by_id       :bigint           not null
#  source_id           :string
#  workspace_id        :bigint           not null
#
# Indexes
#
#  index_events_on_created_by_id               (created_by_id)
#  index_events_on_workspace_id                (workspace_id)
#  index_events_on_workspace_id_and_i_cal_uid  (workspace_id,i_cal_uid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
FactoryBot.define do
  factory :event do
    workspace
    created_by
    name { "Testing" }
    start_time { Time.current }
    end_time { Time.current + 2.hours }
  end
end
