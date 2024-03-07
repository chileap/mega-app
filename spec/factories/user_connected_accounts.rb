# == Schema Information
#
# Table name: user_connected_accounts
#
#  id                    :bigint           not null, primary key
#  access_token          :string
#  access_token_secret   :string
#  app_specific_password :string
#  auth                  :text
#  calendar_url_tokens   :jsonb            not null
#  email                 :string
#  expires_at            :datetime
#  provider              :string
#  refresh_token         :string
#  uid                   :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :bigint
#  workspace_id          :bigint
#
# Indexes
#
#  index_user_connected_accounts_on_user_id       (user_id)
#  index_user_connected_accounts_on_workspace_id  (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#

FactoryBot.define do
  factory :user_connected_account, class: User::ConnectedAccount do
    provider { "google_oauth2" }
  end
end
