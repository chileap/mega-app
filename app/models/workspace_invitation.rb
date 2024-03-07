# == Schema Information
#
# Table name: workspace_invitations
#
#  id            :bigint           not null, primary key
#  email         :string           not null
#  name          :string           not null
#  roles         :jsonb            not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :bigint
#  workspace_id  :bigint           not null
#
# Indexes
#
#  index_workspace_invitations_on_invited_by_id  (invited_by_id)
#  index_workspace_invitations_on_token          (token) UNIQUE
#  index_workspace_invitations_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
class WorkspaceInvitation < ApplicationRecord
  ROLES = WorkspaceUser::ROLES

  include Rolified

  belongs_to :workspace
  belongs_to :invited_by, class_name: "User", optional: true
  has_secure_token

  validates :name, :email, presence: true
  validates :email, uniqueness: {scope: :workspace_id, message: :invited}

  def save_and_send_invite
    if save
      WorkspaceInvitationsMailer.with(workspace_invitation: self).invite.deliver_later
    end
  end

  def accept!(user)
    workspace_user = workspace.workspace_users.new(user: user, roles: roles)
    if workspace_user.valid?
      ApplicationRecord.transaction do
        workspace_user.save!
        destroy!
      end

      [workspace.owner, invited_by].uniq.each do |recipient|
        AcceptedInvite.with(workspace: workspace, user: user).deliver_later(recipient)
      end

      workspace_user
    else
      errors.add(:base, workspace_user.errors.full_messages.first)
      nil
    end
  end

  def reject!
    destroy
  end

  def to_param
    token
  end
end
