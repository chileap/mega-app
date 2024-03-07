class AddDetailsToConnectedAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :user_connected_accounts, :email, :string
    add_column :user_connected_accounts, :app_specific_password, :string
    add_column :user_connected_accounts, :calendar_url_tokens, :jsonb, default: {}, null: false
  end
end
