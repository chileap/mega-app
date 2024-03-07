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
require "rails_helper"

RSpec.describe Webhook, type: :model do
  describe "associations" do
    it { should belong_to(:created_by) }
    it { should belong_to(:workspace) }
    it { should belong_to(:connected_account).optional }
  end
end
