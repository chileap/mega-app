class AddWorkspaceUsersCountToWorkspaces < ActiveRecord::Migration[7.0]
  def change
    add_column :workspaces, :workspace_users_count, :integer, default: 0, null: false
  end
end
