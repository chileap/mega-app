module UserWorkspaces
  extend ActiveSupport::Concern

  included do
    has_many :workspace_invitations, dependent: :nullify, foreign_key: :invited_by_id
    has_many :workspace_users, dependent: :destroy
    has_many :workspaces, through: :workspace_users
    has_many :owned_workspaces, class_name: "Workspace", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy
    has_one :personal_workspace, -> { where(personal: true) }, class_name: "Workspace", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy
    has_many :events, through: :workspaces

    # Regular users should get their workspace created immediately
    after_create :create_default_workspace, unless: :skip_default_workspace?
    after_update :sync_personal_workspace_name, if: -> { Jumpstart.config.personal_workspaces }

    accepts_nested_attributes_for :owned_workspaces, reject_if: :all_blank

    # Used for skipping a default workspace on create
    attribute :skip_default_workspace, :boolean, default: false
  end

  def create_default_workspace
    # Invited users don't have a name immediately, so we will run this method twice for them
    # once on create where no name is present and again on accepting the invitation
    return unless name.present?
    return workspaces.first if workspaces.any?

    workspace = workspaces.new(owner: self, name: name, personal: Jumpstart.config.personal_workspaces)
    workspace.workspace_users.new(user: self, admin: true)
    workspace.save!
    workspace
  end

  def sync_personal_workspace_name
    if first_name_previously_changed? || last_name_previously_changed?
      # Accepting an invitation calls this when the user's name is updated
      if personal_workspace.nil?
        create_default_workspace
        reload_personal_workspace
      end

      # Sync the personal workspace name with the user's name
      personal_workspace.update(name: name)
    end
  end
end
