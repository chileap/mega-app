# == Schema Information
#
# Table name: habits
#
#  id               :bigint           not null, primary key
#  description      :text
#  end_date         :date
#  frequency        :string
#  goal_periodicity :string           default("daily")
#  goal_unit        :string           default("times")
#  goal_value       :integer          default(1)
#  repeat           :text
#  start_date       :date
#  status           :string           default("pending")
#  time             :datetime
#  title            :string
#  type             :string
#  value            :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  created_by_id    :bigint           not null
#  goal_id          :bigint           not null
#  workspace_id     :bigint           not null
#
# Indexes
#
#  index_habits_on_created_by_id  (created_by_id)
#  index_habits_on_goal_id        (goal_id)
#  index_habits_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (goal_id => goals.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
class Habit < ApplicationRecord
  extend Enumerize
  PERIODICITY = {daily: "Per Day", weekly: "Per Week", monthly: "Per Month"}.freeze

  self.inheritance_column = :_type_disabled

  belongs_to :created_by, class_name: "User"
  belongs_to :workspace
  belongs_to :goal, counter_cache: true

  has_many :goal_trackers, dependent: :destroy

  enumerize :type, in: %w[run walk exercise workout drink_water no_sugar], predicates: true, scope: true
  enumerize :frequency, in: %w[daily weekly monthly], default: "daily", predicates: true, scope: true
  enumerize :status, in: %w[pending completed], default: "pending", predicates: true, scope: true
  enumerize :goal_periodicity, in: %w[daily weekly monthly], default: "daily", predicates: true, scope: true
  enumerize :goal_unit, in: [:times, :min, :hours, :steps, :kg, :grams, :mg, :oz, :pounds, :litres, :ml, :cups, :kilojoule, :cal, :kcal, :joules, :km, :metres, :feet, :yards, :miles], default: "times", predicates: true, scope: true

  validates :title, presence: true

  delegate :title, :start_date, :end_date, to: :goal, prefix: true

  scope :have_date, -> { where.not(start_date: nil, end_date: nil) }
  scope :have_time, -> { where.not(time: nil) }
  scope :active, -> { where("#{table_name}.start_date <= ?", Time.current).where("#{table_name}.end_date >= ?", Time.current) }

  def update_habit_status
    return unless percentage_completed >= 1
    update(status: "completed")
  end

  def self.filter_by(params)
    habits = all
    habits = habits.where(type: params[:type]) if params[:type].present?
    habits = habits.where(frequency: params[:frequency]) if params[:frequency].present?
    habits = habits.have_date.where(start_date: (params[:start].to_date)..(params[:end].to_date)) if params[:start].present? && params[:end].present?
    habits
  end

  def self.to_remind
    current_time = TimeService.new(Time.now).concat_time
    active.have_time.where(time: (current_time + 10.minutes)..(current_time + 11.minutes))
  end

  def self.number_of_completed_day(goal_id)
    count_goal_trackers = joins(:goal_trackers).group("habits.id, tracked_date").select([
      "habits.*",
      "coalesce(SUM(goal_trackers.value), 0) AS goal_trackers_value",
      "DATE(goal_trackers.tracked_at) AS tracked_date"
    ])
    select("*").from(count_goal_trackers).group("id").where("goal_trackers_value >= goal_value and goal_id = #{goal_id}").count("tracked_date").values.sum
  end

  def self.uncompleted_tracker_by_current_workspace(date, workspace_id)
    count_goal_trackers = joins("LEFT JOIN (#{GoalTracker.tracked_at(date).to_sql}) AS gt ON gt.habit_id = habits.id").group("habits.id").select(
      "habits.*,
      coalesce(SUM(gt.value), 0) AS goal_trackers_value"
    )
    select("*").from(count_goal_trackers).where("goal_trackers_value < goal_value and workspace_id = #{workspace_id}").where("start_date  <= ? and end_date >= ?", date, date)
  end

  def self.uncompleted_tracker(date, goal_id)
    count_goal_trackers = joins("LEFT JOIN (#{GoalTracker.tracked_at(date).to_sql}) AS gt ON gt.habit_id = habits.id").group("habits.id").select(
      "habits.*,
      coalesce(SUM(gt.value), 0) AS goal_trackers_value"
    )
    select("*").from(count_goal_trackers).where("goal_trackers_value < goal_value and goal_id = #{goal_id}").where("start_date  <= ? and end_date >= ?", date, date)
  end

  def self.tracker_completed_at(date, goal_id)
    count_goal_trackers = joins("LEFT JOIN (#{GoalTracker.tracked_at(date).to_sql}) AS gt ON gt.habit_id = habits.id").group("habits.id").select(
      "habits.*,
      coalesce(SUM(gt.value), 0) AS goal_trackers_value"
    )
    select("*").from(count_goal_trackers).where("goal_trackers_value >= goal_value and goal_id = #{goal_id}")
  end

  def percentage_completed
    return 0 if duration.zero?

    number_of_completed_days.to_f / duration.to_f
  end

  def duration
    return 1 if start_date.present? && end_date.blank?
    return 0 unless start_date.present? && end_date.present?

    (end_date.to_date - start_date.to_date).to_i + 1
  end

  def self.number_of_completed_days(goal_id, habit_id)
    habits = Habit.joins(:goal_trackers).group("habits.id, tracked_date").select([
      "habits.*",
      "coalesce(SUM(goal_trackers.value), 0) AS goal_trackers_value",
      "DATE(goal_trackers.tracked_at) AS tracked_date"
    ])

    select("*").from(habits).group("id").where("goal_trackers_value >= goal_value and goal_id = #{goal_id} and id = #{habit_id}").count("tracked_date").values.sum
  end

  def number_of_completed_days
    habits = Habit.joins(:goal_trackers).group("habits.id, tracked_date").select([
      "habits.*",
      "coalesce(SUM(goal_trackers.value), 0) AS goal_trackers_value",
      "DATE(goal_trackers.tracked_at) AS tracked_date"
    ])

    Habit.select("*").from(habits).group("id").where("goal_trackers_value >= goal_value and goal_id = #{goal_id} and id = #{id}").count("tracked_date").values.sum
  end

  def all_completed?
    percentage_completed.to_i == 1
  end

  def is_completed?(date)
    number_value_of_goal_trackers(date) >= goal_value
  end

  def number_value_of_goal_trackers(date)
    goal_trackers.tracked_at(date).sum(:value)
  end

  def first_day_of_tracking
    goal_trackers.order(tracked_at: :asc).first&.tracked_at&.to_date
  end

  def last_day_of_tracking
    goal_trackers.order(tracked_at: :desc).first&.tracked_at&.to_date
  end

  def icon_type
    case type
    when "exercise", "workout"
      "dumbbell"
    when "drink_water"
      "water"
    when "no_sugar"
      "cookie"
    else
      "running"
    end
  end

  def start_date_time
    return nil unless start_date.present?
    if time.present?
      "#{start_date.strftime("%Y-%m-%d")} #{time.strftime("%H:%M")}".in_time_zone
    else
      start_date.in_time_zone
    end
  end

  def end_date_time
    return nil unless end_date.present?
    if time.present?
      "#{end_date.strftime("%Y-%m-%d")} #{time.strftime("%H:%M")}".in_time_zone
    else
      end_date.in_time_zone
    end
  end

  def frequency_text
    case frequency
    when "daily"
      "a day"
    when "weekly"
      "a week"
    when "monthly"
      "a month"
    end
  end

  def rrule
    {
      freq: frequency,
      dtstart: start_date_time,
      until: end_date
    }
  end

  def tracked_today?
    goal_trackers.where(tracked_at: Date.today.all_day).any?
  end

  def today_tracker
    goal_trackers.where(tracked_at: Date.today.all_day).first
  end

  def remind_user
    return if tracked_today?

    HabitReminder.with(habit: self, workspace: workspace).deliver_later(created_by)
  end

  def undo_completed(date)
    goal_trackers.where(tracked_at: date.all_day).destroy_all
  end
end
