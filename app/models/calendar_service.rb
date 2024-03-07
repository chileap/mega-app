# == Schema Information
#
# Table name: calendar_services
#
#  id             :bigint           not null, primary key
#  etag           :string
#  i_cal_uid      :string           not null
#  import_type    :string           not null
#  name           :string           not null
#  payload        :text
#  provider       :string           not null
#  url            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  event_id       :bigint           not null
#  imported_by_id :bigint           not null
#  source_id      :string
#
# Indexes
#
#  index_calendar_services_on_event_id                             (event_id)
#  index_calendar_services_on_event_id_and_i_cal_uid_and_provider  (event_id,i_cal_uid,provider) UNIQUE
#  index_calendar_services_on_imported_by_id                       (imported_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (imported_by_id => users.id)
#
class CalendarService < ApplicationRecord
  extend Enumerize

  belongs_to :event
  belongs_to :imported_by, class_name: "User"

  validates :name, presence: true
  validates :provider, presence: true
  validates :url, presence: true
  validates :i_cal_uid, presence: true, uniqueness: {scope: %i[event_id provider]}

  delegate :workspace, to: :event

  enumerize :provider, in: %i[google_oauth2 microsoft_graph apple yahoo], predicates: true, scope: true
  enumerize :import_type, in: %i[webhook manual local], predicates: true, scope: true
end
