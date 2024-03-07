# == Schema Information
#
# Table name: goals
#
#  id            :bigint           not null, primary key
#  color         :string
#  completed_at  :datetime
#  description   :text
#  end_date      :datetime
#  habits_count  :integer          default(0)
#  start_date    :datetime
#  title         :string
#  type          :string
#  value         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint           not null
#  workspace_id  :bigint           not null
#
# Indexes
#
#  index_goals_on_created_by_id  (created_by_id)
#  index_goals_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
class Goal < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :created_by, class_name: "User"
  belongs_to :workspace
  has_many :habits, dependent: :destroy
  has_many :goal_trackers, through: :habits

  accepts_nested_attributes_for :habits, reject_if: ->(attributes) { attributes["type"].blank? }, allow_destroy: true

  after_initialize :set_default_color

  validates :title, presence: true
  validate :must_have_end_date_if_start_date_present
  validate :end_date_cannot_be_before_start_date

  default_scope { order(completed_at: :asc) }

  scope :active, -> { where("#{table_name}.start_date <= ?", Time.current).where("#{table_name}.end_date >= ?", Time.current) }
  scope :not_completed, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :include_completed, -> { completed.or(not_completed) }

  def self.filter_by(params)
    goals = all

    goals = goals.where("title ilike ?", "%#{params[:title]}%") if params[:title].present?

    if params[:show_completed].present? && params[:show_completed] == "true"
      goals.include_completed
    else
      goals.not_completed
    end
  end

  def self.number_completed_by(view_by)
    case view_by
    when "30days"
      where("date(completed_at) >= ? and date(completed_at) <= ?", Time.current - 30.days, Time.current).count
    when "all"
      completed.count
    else
      where("date(completed_at) >= ? and date(completed_at) <= ?", Time.current - 7.days, Time.current).count
    end
  end

  def self.percentage_completed_by(view_by)
    return 0 if number_of_goals_within(view_by).zero?
    number_completed_by(view_by).to_f / number_of_goals_within(view_by).to_f * 100
  end

  def self.number_of_goals_within(view_by)
    case view_by
    when "30days"
      where("date(start_date) >= ? and date(start_date) <= ?", Time.current - 30.days, Time.current).count
    when "all"
      count
    else
      where("date(start_date) >= ? and date(start_date) <= ?", Time.current - 7.days, Time.current).count
    end
  end

  def set_default_color
    return unless ActiveRecord::Base.connection.column_exists?(:goals, :color)
    self.color ||= "##{SecureRandom.hex(3)}"
  end

  def update_completion_status
    return unless completed_at.blank?

    if habits.all?(&:completed?)
      completed!
    end
  end

  def duration
    return 0 if start_date.blank?

    if end_date.present?
      (end_date.to_date - start_date.to_date).to_i
    else
      (Date.today - start_date.to_date).to_i
    end
  end

  def duration_time_left
    return 0 if start_date.blank?

    if end_date.present?
      (end_date.to_date - Date.today).to_i
    end
  end

  def number_of_completions
    Habit.number_of_completed_day(id)
  end

  def completed?
    completed_at.present?
  end

  def completed!
    update!(completed_at: Time.current)
  end

  def uncompleted!
    update!(completed_at: nil)
  end

  def goal_process
    return 0 if habits.blank?

    habits.map(&:percentage_completed).sum / habits.count
  end

  def before_goal_image
    goal_trackers.have_value_and_image.order("created_at asc").first&.image
  end

  def progressing_goal_image
    goal_trackers.have_value_and_image.order("created_at desc").first&.image
  end

  def total_pending_habits
    habits.with_status(:pending).count
  end

  private

  def must_have_end_date_if_start_date_present
    return if end_date.present? || start_date.blank?

    errors.add(:end_date, "must be present if start date is present")
  end

  def end_date_cannot_be_before_start_date
    return if end_date.blank? || start_date.blank?

    errors.add(:end_date, "can't be before start date") if end_date < start_date
  end
end
