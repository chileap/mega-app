# == Schema Information
#
# Table name: workspace_users
#
#  id           :bigint           not null, primary key
#  roles        :jsonb            not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint
#  workspace_id :bigint
#
# Indexes
#
#  index_workspace_users_on_user_id       (user_id)
#  index_workspace_users_on_workspace_id  (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#

class WorkspaceUser < ApplicationRecord
  # Add workspace roles to this line
  # Do NOT to use any reserved words like `user` or `workspace`
  ROLES = [:admin, :member]

  include Rolified

  belongs_to :workspace, counter_cache: true
  belongs_to :user

  validates :user_id, uniqueness: {scope: :workspace_id}
  validate :owner_must_be_admin, on: :update, if: -> { admin_changed? && workspace_owner? }

  def workspace_owner?
    workspace.owner_id == user_id
  end

  def owner_must_be_admin
    unless admin?
      errors.add :admin, :cannot_be_removed
    end
  end
end
