class CreateWebhooks < ActiveRecord::Migration[7.0]
  def change
    create_table :webhooks do |t|
      t.references :account, null: false
      t.references :created_by, null: false, foreign_key: {to_table: :users}
      t.string :resource_id
      t.string :kind
      t.string :resource_uri
      t.string :token
      t.string :expiration
      t.string :next_sync_token
      t.string :channel_id
      t.timestamps
    end
  end
end
