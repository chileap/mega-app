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
class TimeboxingItem < ApplicationRecord
  belongs_to :user
  belongs_to :workspace
  belongs_to :timeboxing, counter_cache: true

  validates :name, presence: true
  validate :start_time_before_end_time
  validate :start_time_must_be_in_timeboxing_date
  validate :end_time_must_be_in_timeboxing_date
  validate :must_have_both_start_and_end_time

  default_scope { order(created_at: :asc) }

  scope :completed, -> { where.not(completed_at: nil) }
  scope :uncompleted, -> { where(completed_at: nil) }
  scope :priority, -> { where(priority: true) }
  scope :brain_dump, -> { where(priority: false) }
  scope :has_time, -> { where.not(start_time: nil, end_time: nil) }
  scope :scheduled, -> { has_time.uncompleted }
  scope :unscheduled, -> { where(start_time: nil, end_time: nil).uncompleted }
  scope :transferable, -> { where(completed_at: nil) }
  scope :not_transferable, -> { where.not(completed_at: nil) }

  def self.filter_by(params)
    timeboxing_items = all
    timeboxing_items = timeboxing_items.where(start_time: (params[:start].to_date)..(params[:end].to_date)) if params[:start].present? && params[:end].present?
    timeboxing_items
  end

  def completed?
    completed_at.present?
  end

  def uncompleted?
    completed_at.blank?
  end

  def color
    return "#F44336" if priority?
    "#d1d5db"
  end

  def background_color
    return "#fdba74" if priority?
    "#f3f4f6"
  end

  def text_color
    return "#ffffff" if priority?
    "#374151"
  end

  def duration
    return "00:30:00" unless start_time && end_time

    minutes = (end_time - start_time) / 1.hour

    if minutes < 1

      minutes = ((minutes * 60).to_i < 10) ? "0#{(minutes * 60).to_i}" : (minutes * 60).to_i

      "00:#{minutes}:00"
    else

      hour = (minutes.to_i < 10) ? "0#{minutes.to_i}" : minutes.to_i
      minutes = (minutes - minutes.to_i) * 60
      "#{hour}:#{minutes.round}:00"
    end
  end

  def time
    return unless start_time && end_time

    start_time_str = start_time.strftime("%l:%M %p")

    if start_time.strftime("%M") == "00"
      start_time_str = start_time.strftime("%l %p")
    end

    end_time_str = end_time.strftime("%l:%M %p")

    if end_time.strftime("%M") == "00"
      end_time_str = end_time.strftime("%l %p")
    end

    "#{start_time_str} - #{end_time_str}"
  end

  def able_to_transfer_to_next_day?
    return false if completed?

    true
  end

  def transfer_to_next_day
    return unless able_to_transfer_to_next_day?

    next_day = timeboxing.date + 1.day
    new_timeboxing = Timeboxing.find_or_create_by(date: next_day, user: user, workspace: workspace)
    new_timeboxing_item = TimeboxingItem.new dup.attributes.except("id", "created_at", "updated_at", "completed_at", "timeboxing_id", "start_time", "end_time")
    new_timeboxing_item.timeboxing_id = new_timeboxing.id
    new_timeboxing_item.save
  end

  def undo_schedule
    return unless start_time.present? && end_time.present?

    self.start_time = nil
    self.end_time = nil
    save
  end

  def json_data
    {
      id: id,
      priority: priority,
      title: name,
      color: color,
      textColor: "#000",
      duration: duration,
      start: start_time,
      end: end_time
    }
  end

  private

  def must_have_both_start_and_end_time
    return if start_time.blank? && end_time.blank?

    errors.add(:start_time, "must have both start and end time") if start_time.blank? || end_time.blank?
  end

  def only_three_items_can_be_priority
    return unless priority?

    errors.add(:priority, "only three items can be priority") if timeboxing.timeboxing_items.priority.count >= 3 && !priority_was
  end

  def start_time_before_end_time
    return if start_time.blank? || end_time.blank?

    errors.add(:start_time, "must be before end time") if start_time > end_time
  end

  def start_time_must_be_in_timeboxing_date
    return if start_time.blank?

    errors.add(:start_time, "must be in timeboxing date") if start_time.to_date != timeboxing.date
  end

  def end_time_must_be_in_timeboxing_date
    return if end_time.blank?

    errors.add(:end_time, "must be in timeboxing date") if end_time.to_date != timeboxing.date
  end
end
