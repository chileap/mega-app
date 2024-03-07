class AddPayloadToWebhook < ActiveRecord::Migration[7.0]
  def change
    add_column :webhooks, :payload, :jsonb, null: false, default: {}
    remove_column :webhooks, :page_token
  end
end
