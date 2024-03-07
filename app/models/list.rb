# == Schema Information
#
# Table name: lists
#
#  id            :bigint           not null, primary key
#  default       :boolean          default(FALSE)
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint
#  workspace_id  :bigint
#
# Indexes
#
#  index_lists_on_created_by_id  (created_by_id)
#  index_lists_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#
class List < ApplicationRecord
  belongs_to :workspace
  belongs_to :created_by, class_name: "User"
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validate :can_destroy?, on: :destroy
  validate :should_have_only_one_default_list
  validate :cannot_update_default_list, on: :update

  def total_tasks
    tasks.count
  end

  private

  def cannot_update_default_list
    return unless default?

    errors.add(:base, "Cannot update default list")
    throw(:abort)
  end

  def should_have_only_one_default_list
    return unless default?

    if workspace.lists.where(default: true).where.not(id: id).any?
      errors.add(:base, "Cannot have more than one default list")
      throw(:abort)
    end
  end

  def can_destroy?
    return true unless default?

    errors.add(:base, "Cannot delete default list")
    throw(:abort)
  end
end
