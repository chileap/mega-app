# == Schema Information
#
# Table name: lists
#
#  id            :bigint           not null, primary key
#  default       :boolean          default(FALSE)
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint
#  workspace_id  :bigint
#
# Indexes
#
#  index_lists_on_created_by_id  (created_by_id)
#  index_lists_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#
require "rails_helper"

RSpec.describe List, type: :model do
  describe "associations" do
    it { should belong_to(:created_by) }
    it { should belong_to(:workspace) }
    it { should have_many(:tasks) }
  end
end
