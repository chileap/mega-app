class AddWorkspaceIdToConnectedAccounts < ActiveRecord::Migration[7.0]
  def change
    add_reference :user_connected_accounts, :workspace, index: true, foreign_key: true

    # Add workspace_id to existing connected accounts
    User::ConnectedAccount.find_each do |connected_account|
      workspace_id = connected_account.user.personal_workspace.id
      connected_account.update(workspace_id: workspace_id)
    end
  end
end
