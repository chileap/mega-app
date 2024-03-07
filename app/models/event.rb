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
class Event < ApplicationRecord
  extend Enumerize

  REPEAT_OPTIONS = %w[never daily weekly monthly yearly].freeze
  PROVIDER_OPTIONS = %w[google_oauth2 apple yahoo microsoft_graph].freeze

  belongs_to :workspace
  belongs_to :created_by, class_name: "User"
  has_many :calendar_services, dependent: :destroy

  enumerize :source_type, in: [:default, :google_oauth2, :apple, :yahoo, :microsoft_graph], default: :default, scope: true, predicates: true
  enumerize :status, in: [:confirmed, :cancelled, :tentative], default: :confirmed, scope: true, skip_validations: true
  enumerize :repeat, in: REPEAT_OPTIONS, default: :never, scope: true, skip_validations: true

  delegate :name, to: :workspace, prefix: :workspace
  delegate :name, to: :created_by, prefix: :created_by

  validates :start_time, :end_time, :name, presence: true
  validates :i_cal_uid, uniqueness: {scope: :workspace_id, allow_blank: true}
  validates :etag, uniqueness: {scope: :source_type, allow_blank: true}
  validates :event_url, uniqueness: {scope: :source_type, allow_blank: true}

  validate :end_time_is_after_start_time

  scope :on_day, ->(start_time) { where("DATE(start_time) <= ? and DATE(end_time) >= ?", start_time.to_date, start_time.to_date) }
  scope :on_month, ->(date) { where("EXTRACT(MONTH FROM start_time) = ? or EXTRACT(MONTH FROM end_time) = ?", date.month, date.month) }
  scope :recurring_events, -> { where.not(repeat: "never") }
  scope :non_recurring_events, -> { where(repeat: "never") }

  def self.search_by_start_date(date)
    return on_day(date) if date.present?
    self
  end

  def self.search_by(params)
    events = all

    if params[:view_by].present?
      events = if params[:view_by] == "30days"
        events.where("start_time >= ? and end_time <= ?", Time.current.beginning_of_day, Time.current.end_of_day + 30.days)
      elsif params[:view_by] == "all"
        events
      else
        events.where("start_time >= ? and end_time <= ?", Time.current.beginning_of_day, Time.current.end_of_day + 7.days)
      end
    end

    events
  end

  def self.filter_by(params)
    events = all

    if params[:start].present? && params[:end].present?
      events = events.recurring_events.or(where("DATE(start_time) >= ? and DATE(start_time) <= ?", params[:start].to_date, params[:end].to_date))
    end

    events
  end

  def self.repeat_options
    [
      ["Does not repeat", "never"],
      ["Daily", "daily"],
      ["Weekly", "weekly"],
      ["Monthly", "monthly"],
      ["Annually", "yearly"]
    ]
  end

  def color
    case source_type
    when "google_oauth2"
      "#4285f4"
    when "apple"
      "#ff3b30"
    when "yahoo"
      "#720e9e"
    when "microsoft_graph"
      "#00a1f1"
    else
      "#287f58"
    end
  end

  def is_same_day?
    start_time.to_date == end_time.to_date
  end

  def start_date
    start_time.present? ? start_time.in_time_zone.to_date : Time.zone.now.to_date
  end

  def end_date
    end_time.present? ? end_time.in_time_zone.to_date : Time.zone.now.to_date
  end

  def start_date_time
    start_time.present? ? start_time.in_time_zone : Time.zone.now + 1.hour
  end

  def end_date_time
    end_time.present? ? end_time.in_time_zone : Time.zone.now + 2.hours
  end

  def is_overlap?
    !is_same_day?
  end

  def recurring?
    repeat != "never"
  end

  def rrule
    return unless recurring?
    {
      freq: repeat,
      dtstart: all_day ? start_date : start_date_time,
      until: repeat_until_date.present? ? repeat_until_date.to_date.to_s : nil
    }
  end

  def duration
    return unless end_time.present? && start_time.present?

    if all_day?
      (end_time + 1.days - start_time).to_i * 1000
    else
      (end_time - start_time).to_i * 1000
    end
  end

  def repeat_text
    case repeat
    when "never"
      "Does not repeat"
    when "daily"
      "Daily"
    when "weekly"
      if is_same_day?
        "Weekly on #{start_time.strftime("%A")}"
      else
        "Weekly on #{start_time.strftime("%A")} - #{end_time.strftime("%A")}"
      end
    when "monthly"
      if is_same_day?
        "Monthly on #{start_time.strftime("%d")}"
      else
        "Monthly on #{start_time.strftime("%d")} - #{end_time.strftime("%d")}"
      end
    when "yearly"
      if is_same_day?
        "Annually on #{start_time.strftime("%B %d")}"
      else
        "Annually on #{start_time.strftime("%B %d")} - #{end_time.strftime("%B %d")}"
      end
    else
      "Does not repeat"
    end
  end

  def exdate
    return unless recurring?
    if all_day?
      repeat_except_dates.map { |date| date.to_datetime.strftime("%Y%m%d") }
    else
      repeat_except_dates.map { |date| date.to_datetime.strftime("%Y%m%dT%H%M%S") }
    end
  end

  def until_date
    return unless recurring?
    if all_day?
      repeat_until_date.to_date.strftime("%Y%m%d")
    else
      repeat_until_date.to_datetime.strftime("%Y%m%dT%H%M%SZ")
    end
  end

  def ical_recurrence
    return [] unless recurring?

    recurrence = ["FREQ=#{repeat.upcase}"]

    if repeat_until_date.present?
      recurrence = ["FREQ=#{repeat.upcase};UNTIL=#{until_date}"]
    end

    if repeat_except_dates.present? && all_day?
      recurrence << "EXDATE:#{exdate.join(",")}"
    elsif repeat_except_dates.present?
      recurrence << "EXDATE;TZID=#{ActiveSupport::TimeZone[time_zone].tzinfo.name}:#{exdate.join(",")}"
    end
    recurrence
  end

  def google_recurrence
    return [] unless recurring?

    recurrence = ["FREQ=#{repeat.upcase}"]

    if repeat_until_date.present?
      recurrence = ["RRULE:FREQ=#{repeat.upcase};UNTIL=#{until_date}"]
    end

    if repeat_except_dates.present? && all_day?
      recurrence << "EXDATE:#{exdate.join(",")}"
    elsif repeat_except_dates.present?
      recurrence << "EXDATE;TZID=#{ActiveSupport::TimeZone[time_zone].tzinfo.name}:#{exdate.join(",")}"
    end
    recurrence
  end

  private

  def end_time_is_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time < start_time
      errors.add(:end_time, "cannot be before the start date")
    end
  end
end
