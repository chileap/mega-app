class CreateContactGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_groups do |t|
      t.string :name
      t.integer :contacts_count

      t.boolean :default, default: false
      t.references :account, null: false, foreign_key: true
      t.references :created_by, forieng_key: {to_table: :users}, null: false

      t.timestamps
    end

    if ActiveRecord::Base.connection.table_exists?("workspaces") && ActiveRecord::Base.connection.table_exists?("workspace_users")
      WorkspaceUser.all.find_each do |account_user|
        account_user.account.contact_groups.create!(name: "All Contacts", default: true, created_by: account_user.user)
      end
    end
  end
end
