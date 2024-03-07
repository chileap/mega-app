class AddProviderAndConnectedAccountsToWebhooks < ActiveRecord::Migration[7.0]
  def change
    add_column :webhooks, :provider, :string
    add_reference :webhooks, :connected_account, foreign_key: {to_table: :user_connected_accounts}

    Webhook.all.each do |webhook|
      connected_account = webhook.created_by.connected_accounts.google_oauth2.first
      webhook.update(
        provider: :google,
        connected_account: connected_account
      )
    end
  end
end
