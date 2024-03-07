# == Schema Information
#
# Table name: workspace_users
#
#  id           :bigint           not null, primary key
#  roles        :jsonb            not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint
#  workspace_id :bigint
#
# Indexes
#
#  index_workspace_users_on_user_id       (user_id)
#  index_workspace_users_on_workspace_id  (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#

require "test_helper"

class WorkspaceUserTest < ActiveSupport::TestCase
  test "converts roles to booleans" do
    member = WorkspaceUser.new admin: "1"
    assert_equal true, member.admin
  end

  test "can be assigned a role" do
    member = WorkspaceUser.new admin: true
    assert_equal true, member.admin
    assert_equal true, member.admin?
  end

  test "role can be false" do
    member = WorkspaceUser.new admin: false
    assert_equal false, member.admin
    assert_equal false, member.admin?
  end

  test "keeps track of active roles" do
    member = WorkspaceUser.new admin: true
    assert_equal [:admin], member.active_roles
  end

  test "has no active roles" do
    member = WorkspaceUser.new admin: false
    assert_empty member.active_roles
  end

  test "owner cannot remove the admin role" do
    member = workspace_users(:company_admin)
    assert member.workspace_owner?
    member.update(admin: false)
    assert_not member.valid?
  end
end
