# == Schema Information
#
# Table name: tasks
#
#  id            :bigint           not null, primary key
#  completed_at  :datetime
#  due_all_day   :boolean          default(TRUE)
#  due_date      :datetime
#  flagged_at    :datetime
#  name          :string           not null
#  notes         :text
#  priority      :integer          default("none")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint           not null
#  list_id       :bigint
#  workspace_id  :bigint           not null
#
# Indexes
#
#  index_tasks_on_created_by_id  (created_by_id)
#  index_tasks_on_list_id        (list_id)
#  index_tasks_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
class Task < ApplicationRecord
  extend Enumerize

  belongs_to :workspace
  belongs_to :created_by, class_name: "User"
  belongs_to :list

  delegate :name, to: :list, prefix: :list

  enumerize :priority, in: {none: 0, low: 1, medium: 2, high: 3}, default: :none

  validates :name, presence: true

  scope :ordered, -> { order(updated_at: :desc) }
  scope :not_completed, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :flagged, -> { where.not(flagged_at: nil) }
  scope :not_flagged, -> { where(flagged_at: nil) }
  scope :have_due_date, -> { where.not(due_date: nil) }
  scope :scheduled, -> { where("completed_at is null and due_date is not null and DATE(due_date) >= ?", Time.current.end_of_day.to_date) }
  scope :due_today, -> { have_due_date.where(due_date: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :filter_by_name, ->(name) { where("name ilike ?", "%#{name}%") }
  scope :include_completed, -> { completed.or(not_completed) }
  scope :high_priority, -> { where(priority: 3) }
  scope :today_high_priority, -> { high_priority.due_today }

  def completed?
    completed_at.present?
  end

  def flagged?
    flagged_at.present?
  end

  def over_deadline?
    (due_date.present? && due_date.to_date < Date.today) || completed_on_the_past_date?
  end

  def completed_on_the_past_date?
    completed_at.present? && completed_at.to_date < Date.today
  end

  def due_time
    due_date.strftime("%I:%M %p") if due_date.present?
  end

  def self.filter_by(params)
    tasks = all

    if params[:start].present? && params[:end].present?
      tasks = tasks.where("DATE(due_date) >= ? and DATE(due_date) <= ?", params[:start].to_date, params[:end].to_date)
    end

    if params[:search].present?
      tasks = tasks.filter_by_name(params[:search])
    end

    tasks = if params[:show_completed].present? && params[:show_completed] == "true"
      tasks.include_completed
    else
      tasks.not_completed
    end

    if params[:view].present?
      if params[:view] == "scheduled"
        tasks = tasks.scheduled
      elsif params[:view] == "today"
        tasks = tasks.due_today
      elsif params[:view] == "flagged"
        tasks = tasks.flagged
      end
    end

    if params[:list_id].present?
      tasks = tasks.where(list_id: params[:list_id])
    end

    if params[:sort_by].present?
      sort_rule = params[:sort_rule].present? ? params[:sort_rule] : "asc"
      tasks = tasks.order("#{params[:sort_by]}": sort_rule.to_s)
    end

    if params[:allDay].present?
      tasks = tasks.where(due_all_day: params[:allDay])
    end

    tasks
  end

  def self.search_by(params)
    tasks = all

    if params[:view_by].present?
      tasks = if params[:view_by] == "30days"
        tasks.where("due_date >= ? and due_date <= ?", Time.current.beginning_of_day, Time.current.end_of_day + 30.days)
      elsif params[:view_by] == "all"
        tasks
      else
        tasks.where("due_date >= ? and due_date <= ?", Time.current.beginning_of_day, Time.current.end_of_day + 7.days)
      end
    end

    tasks
  end

  def self.number_not_completed_by(view_by)
    case view_by
    when "30days"
      not_completed.where("due_date >= ? and due_date <= ?", Time.current.beginning_of_day, Time.current.end_of_day + 30.days).count
    when "all"
      not_completed.count
    else
      not_completed.where("due_date >= ? and due_date <= ?", Time.current.beginning_of_day, Time.current.end_of_day + 7.days).count
    end
  end

  def self.number_completed_by(view_by)
    case view_by
    when "30days"
      completed.where("completed_at >= ? and completed_at <= ?", Time.current.beginning_of_day, Time.current.end_of_day + 30.days).count
    when "all"
      completed.count
    else
      completed.where("completed_at >= ? and completed_at <= ?", Time.current.beginning_of_day, Time.current.end_of_day + 7.days).count
    end
  end

  def self.number_flagged_by(view_by)
    case view_by
    when "30days"
      flagged.where("flagged_at >= ? and flagged_at <= ?", Time.current.beginning_of_day, Time.current.end_of_day + 30.days).count
    when "all"
      flagged.count
    else
      flagged.where("flagged_at >= ? and flagged_at <= ?", Time.current.beginning_of_day, Time.current.end_of_day + 7.days).count
    end
  end
end
