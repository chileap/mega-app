class RenameAccountsToWorkspaces < ActiveRecord::Migration[7.0]
  def change
    rename_table :accounts, :workspaces
    rename_table :account_users, :workspace_users
    rename_table :account_invitations, :workspace_invitations
    rename_column :tasks, :account_id, :workspace_id
    rename_column :events, :account_id, :workspace_id
    rename_column :workspace_users, :account_id, :workspace_id
    rename_column :workspace_invitations, :account_id, :workspace_id
    rename_column :contact_groups, :account_id, :workspace_id
    rename_column :contacts, :account_id, :workspace_id
    rename_column :favorite_meal_templates, :account_id, :workspace_id
    rename_column :lists, :account_id, :workspace_id
    rename_column :meals, :account_id, :workspace_id
    rename_column :notifications, :account_id, :workspace_id
    rename_column :webhooks, :account_id, :workspace_id

    rename_index :favorite_meal_templates, "index_favorite_meals_on_user_id_and_meal_temp_id_and_account_id", "index_fav_meals_on_user_id_and_meal_temp_id_and_workspace_id"
  end
end
