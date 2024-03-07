class AddCallbackUrlToWebhooks < ActiveRecord::Migration[7.0]
  def change
    add_column :webhooks, :callback_url, :string
  end
end
