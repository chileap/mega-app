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
require "test_helper"

class WorkspaceTest < ActiveSupport::TestCase
  test "validates against reserved domains" do
    workspace = Workspace.new(domain: Jumpstart.config.domain)
    assert_not workspace.valid?
    assert_not_empty workspace.errors[:domain]
  end

  test "validates against reserved subdomains" do
    subdomain = Workspace::RESERVED_SUBDOMAINS.first
    workspace = Workspace.new(subdomain: subdomain)
    assert_not workspace.valid?
    assert_not_empty workspace.errors[:subdomain]
  end

  test "subdomain format must start with alphanumeric char" do
    workspace = Workspace.new(subdomain: "-abcd")
    assert_not workspace.valid?
    assert_not_empty workspace.errors[:subdomain]
  end

  test "subdomain format must end with alphanumeric char" do
    workspace = Workspace.new(subdomain: "abcd-")
    assert_not workspace.valid?
    assert_not_empty workspace.errors[:subdomain]
  end

  test "must be at least two characters" do
    workspace = Workspace.new(subdomain: "a")
    assert_not workspace.valid?
    assert_not_empty workspace.errors[:subdomain]
  end

  test "can use a mixture of alphanumeric, hyphen, and underscore" do
    [
      "ab",
      "12",
      "a-b",
      "a-9",
      "1-2",
      "1_2",
      "a_3"
    ].each do |subdomain|
      workspace = Workspace.new(subdomain: subdomain)
      workspace.valid?
      assert_empty workspace.errors[:subdomain]
    end
  end

  test "personal workspaces enabled" do
    Jumpstart.config.stub(:personal_workspaces, true) do
      user = User.create! name: "Test", email: "personalworkspaces@example.com", password: "password", password_confirmation: "password", terms_of_service: true
      assert user.workspaces.first.personal?
    end
  end

  test "personal workspaces disabled" do
    Jumpstart.config.stub(:personal_workspaces, false) do
      user = User.create! name: "Test", email: "nonpersonalworkspaces@example.com", password: "password", password_confirmation: "password", terms_of_service: true
      assert_not user.workspaces.first.personal?
    end
  end

  test "owner?" do
    workspace = workspaces(:one)
    assert workspace.owner?(users(:one))
    refute workspace.owner?(users(:two))
  end

  test "can_transfer? false for personal workspaces" do
    refute workspaces(:one).can_transfer?(users(:one))
  end

  test "can_transfer? true for owner" do
    workspace = workspaces(:company)
    assert workspace.can_transfer?(workspace.owner)
  end

  test "can_transfer? false for non-owner" do
    refute workspaces(:company).can_transfer?(users(:two))
  end

  test "transfer ownership to a new owner" do
    workspace = workspaces(:company)
    new_owner = users(:two)
    assert workspaces(:company).transfer_ownership(new_owner.id)
    assert_equal new_owner, workspace.reload.owner
  end

  test "transfer ownership fails transferring to a user outside the workspace" do
    workspace = workspaces(:company)
    owner = workspace.owner
    refute workspace.transfer_ownership(users(:invited).id)
    assert_equal owner, workspace.reload.owner
  end

  test "billing_email shouldn't be included in receipts if empty" do
    workspace = workspaces(:company)
    workspace.update!(billing_email: nil)
    pay_customer = workspace.set_payment_processor :fake_processor, allow_fake: true
    pay_charge = pay_customer.charge(10_00)

    mail = Pay::UserMailer.with(pay_customer: pay_customer, pay_charge: pay_charge).receipt
    assert_equal [workspace.email], mail.to
  end

  test "billing_email should be included in receipts if present" do
    workspace = workspaces(:company)
    workspace.update!(billing_email: "workspaceing@example.com")
    pay_customer = workspace.set_payment_processor :fake_processor, allow_fake: true
    pay_charge = pay_customer.charge(10_00)

    mail = Pay::UserMailer.with(pay_customer: pay_customer, pay_charge: pay_charge).receipt
    assert_equal [workspace.email, "workspaceing@example.com"], mail.to
  end
end
