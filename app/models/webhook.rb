# == Schema Information
#
# Table name: webhooks
#
#  id                   :bigint           not null, primary key
#  callback_url         :string
#  expiration           :string
#  kind                 :string
#  next_sync_token      :string
#  payload              :jsonb            not null
#  provider             :string
#  resource_uri         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  channel_id           :string
#  connected_account_id :bigint
#  created_by_id        :bigint           not null
#  resource_id          :string
#  workspace_id         :bigint           not null
#
# Indexes
#
#  index_webhooks_on_connected_account_id  (connected_account_id)
#  index_webhooks_on_created_by_id         (created_by_id)
#  index_webhooks_on_workspace_id          (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (connected_account_id => user_connected_accounts.id)
#  fk_rails_...  (created_by_id => users.id)
#
class Webhook < ApplicationRecord
  extend Enumerize

  belongs_to :workspace
  belongs_to :created_by, class_name: "User"
  belongs_to :connected_account, class_name: "User::ConnectedAccount", optional: true

  enumerize :provider, in: %i[google_oauth2 microsoft_graph], predicates: true, scope: true

  def expired?
    expiration.to_i < DateTime.current.to_i * 1000
  end
end
