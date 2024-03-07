# == Schema Information
#
# Table name: goal_trackers
#
#  id            :bigint           not null, primary key
#  image_data    :text
#  tracked_at    :datetime
#  unit          :string
#  value         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  habit_id      :bigint           not null
#  tracked_by_id :bigint           not null
#  workspace_id  :bigint
#
# Indexes
#
#  index_goal_trackers_on_habit_id       (habit_id)
#  index_goal_trackers_on_tracked_by_id  (tracked_by_id)
#  index_goal_trackers_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (habit_id => habits.id)
#  fk_rails_...  (tracked_by_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
class GoalTracker < ApplicationRecord
  belongs_to :workspace
  belongs_to :habit
  belongs_to :tracked_by, class_name: "User"

  has_one_attached :image

  delegate :goal, to: :habit

  after_initialize :set_goal_unit

  scope :have_value, -> { where.not(value: nil) }
  scope :have_image, -> { joins(:image_attachment).merge(ActiveStorage::Attachment.where.not(blob_id: nil)) }
  scope :have_value_or_image, -> { where("value IS NOT NULL OR image_data IS NOT NULL") }
  scope :have_value_and_image, -> { have_image.have_value }
  scope :tracked_at, ->(date) { where(tracked_at: date.beginning_of_day..date.end_of_day) }
  scope :tracked_today, -> { tracked_at(Date.today.to_s) }
  scope :tracked_yesterday, -> { tracked_at(Date.yesterday.to_s) }

  after_save :update_habit_completion

  def update_habit_completion
    habit.update_habit_status
    habit.goal.update_completion_status
  end

  def set_goal_unit
    return unless ActiveRecord::Base.connection.column_exists?(:habits, :goal_unit) && ActiveRecord::Base.connection.column_exists?(:goal_trackers, :unit)
    return if habit.blank?
    self.unit ||= habit.goal_unit
  end
end
