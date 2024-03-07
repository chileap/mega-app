# == Schema Information
#
# Table name: notifications
#
#  id             :bigint           not null, primary key
#  interacted_at  :datetime
#  params         :jsonb
#  read_at        :datetime
#  recipient_type :string           not null
#  type           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  recipient_id   :bigint           not null
#  workspace_id   :bigint           not null
#
# Indexes
#
#  index_notifications_on_recipient_type_and_recipient_id  (recipient_type,recipient_id)
#  index_notifications_on_workspace_id                     (workspace_id)
#
require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    Notification.delete_all
  end

  test "notifications with user param are destroyed when user destroyed" do
    user = users(:one)
    AcceptedInvite.with(user: user, workspace: workspaces(:one)).deliver(users(:two))

    assert_difference "Notification.count", -1 do
      user.destroy
    end
  end

  test "notifications with workspace are destroyed when workspace destroyed" do
    workspace = workspaces(:one)
    AcceptedInvite.with(user: users(:one), workspace: workspace).deliver(users(:two))

    assert_difference "Notification.count", -1 do
      workspace.destroy
    end
  end
end
