# == Schema Information
#
# Table name: contact_groups
#
#  id             :bigint           not null, primary key
#  contacts_count :integer
#  default        :boolean          default(FALSE)
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  created_by_id  :bigint           not null
#  workspace_id   :bigint           not null
#
# Indexes
#
#  index_contact_groups_on_created_by_id  (created_by_id)
#  index_contact_groups_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (workspace_id => workspaces.id)
#
class ContactGroup < ApplicationRecord
  belongs_to :workspace
  belongs_to :created_by, class_name: "User"
  has_many :contacts, dependent: :destroy

  validates :name, presence: true
  validate :can_not_destroy_default_group, on: :destroy
  validate :can_not_update_default_group, on: :update
  validate :should_have_only_one_default_group

  private

  def can_not_destroy_default_group
    return unless default?

    errors.add(:base, "You can not delete default group")
    throw(:abort)
  end

  def can_not_update_default_group
    return unless default?

    errors.add(:base, "You can not update default group")
    throw(:abort)
  end

  def should_have_only_one_default_group
    return unless default?

    if workspace.contact_groups.where(default: true).where.not(id: id).any?
      errors.add(:base, "Cannot have more than one default group")
      throw(:abort)
    end
  end
end
