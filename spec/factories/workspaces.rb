# == Schema Information
#
# Table name: workspaces
#
#  id                    :bigint           not null, primary key
#  billing_email         :string
#  domain                :string
#  extra_billing_info    :text
#  name                  :string           not null
#  personal              :boolean          default(FALSE)
#  subdomain             :string
#  workspace_users_count :integer          default(0), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  owner_id              :bigint
#
# Indexes
#
#  index_workspaces_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#

FactoryBot.define do
  factory :workspace do
    name { "MyString" }
    owner
  end
end
