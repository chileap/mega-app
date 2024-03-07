# == Schema Information
#
# Table name: contacts
#
#  id               :bigint           not null, primary key
#  address          :string
#  company_name     :string
#  country_code     :string
#  first_name       :string
#  last_name        :string
#  name             :string
#  phone_number     :string
#  website_url      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  contact_group_id :bigint
#  created_by_id    :bigint           not null
#  workspace_id     :bigint           not null
#
# Indexes
#
#  index_contacts_on_contact_group_id  (contact_group_id)
#  index_contacts_on_created_by_id     (created_by_id)
#  index_contacts_on_workspace_id      (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
FactoryBot.define do
  factory :contact do
  end
end
