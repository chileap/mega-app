# == Schema Information
#
# Table name: contact_groups
#
#  id             :bigint           not null, primary key
#  contacts_count :integer
#  default        :boolean          default(FALSE)
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  created_by_id  :bigint           not null
#  workspace_id   :bigint           not null
#
# Indexes
#
#  index_contact_groups_on_created_by_id  (created_by_id)
#  index_contact_groups_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (workspace_id => workspaces.id)
#
require "rails_helper"

RSpec.describe ContactGroup, type: :model do
  describe "associations" do
    it { should belong_to(:workspace) }
    it { should have_many(:contacts) }
    it { should belong_to(:created_by).class_name("User") }
  end
  describe "validations" do
    it { should validate_presence_of(:name) }
  end
end
