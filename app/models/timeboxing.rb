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
class Timeboxing < ApplicationRecord
  belongs_to :user
  belongs_to :workspace
  has_many :timeboxing_items, dependent: :destroy
  has_many :priority_items, -> { priority }, class_name: "TimeboxingItem"
  has_many :transferable_items, -> { transferable }, class_name: "TimeboxingItem"

  validates :date, presence: true, uniqueness: {scope: [:user_id, :workspace_id]}

  def self.for_date(date:, user:, workspace:)
    find_or_initialize_by(date: date, user: user, workspace: workspace)
  end

  def transfer_notes(new_date: nil)
    next_day = new_date || date + 1.day
    next_day_timeboxing = Timeboxing.find_or_create_by(date: next_day, user: user, workspace: workspace)
    next_day_timeboxing.update(notes: notes)
  end

  def transfer_items(new_date: nil)
    next_day = new_date || date + 1.day
    next_day_timeboxing = Timeboxing.find_or_create_by(date: next_day, user: user, workspace: workspace)
    transfer_timeboxing_items = []

    timeboxing_items.transferable.each do |item|
      new_timeboxing_item = item.dup
      new_timeboxing_item.timeboxing = next_day_timeboxing
      transfer_timeboxing_items << new_timeboxing_item.attributes.except("id", "created_at", "updated_at", "completed_at", "start_time", "end_time")
    end

    TimeboxingItem.upsert_all(transfer_timeboxing_items)
  end

  def destroy_items
    timeboxing_items.destroy_all
  end
end
