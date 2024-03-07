class ChangeTokenToPageTokenInWebhooks < ActiveRecord::Migration[7.0]
  def change
    rename_column :webhooks, :token, :page_token
  end
end
