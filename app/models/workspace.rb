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

class Workspace < ApplicationRecord
  RESERVED_DOMAINS = [Jumpstart.config.domain]
  RESERVED_SUBDOMAINS = %w[app help support]

  belongs_to :owner, class_name: "User"
  has_many :connected_accounts, class_name: "User::ConnectedAccount", dependent: :destroy
  has_many :workspace_invitations, dependent: :destroy
  has_many :workspace_users, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :users, through: :workspace_users
  has_many :events, dependent: :destroy
  has_many :calendar_services, through: :events
  has_many :webhooks, dependent: :destroy
  has_many :meals, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :goal_trackers, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :habits, dependent: :destroy

  has_many :timeboxings, dependent: :destroy
  has_many :timeboxing_items, dependent: :destroy

  has_many :lists, dependent: :destroy
  has_one :default_list, -> { where(default: true) }, class_name: "List"

  has_many :contact_groups, dependent: :destroy
  has_one :default_contact_group, -> { where(default: true) }, class_name: "ContactGroup"

  has_many :contacts, dependent: :destroy
  has_many :addresses, as: :addressable, dependent: :destroy
  has_one :billing_address, -> { where(address_type: :billing) }, class_name: "Address", as: :addressable
  has_one :shipping_address, -> { where(address_type: :shipping) }, class_name: "Address", as: :addressable

  scope :personal, -> { where(personal: true) }
  scope :impersonal, -> { where(personal: false) }
  scope :sorted, -> { order(personal: :desc, name: :asc) }

  has_noticed_notifications
  has_one_attached :avatar
  pay_customer stripe_attributes: :stripe_attributes

  validates :name, presence: true
  validates :domain, exclusion: {in: RESERVED_DOMAINS, message: :reserved}
  validates :subdomain, exclusion: {in: RESERVED_SUBDOMAINS, message: :reserved}, format: {with: /\A[a-zA-Z0-9]+[a-zA-Z0-9\-_]*[a-zA-Z0-9]+\Z/, message: :format, allow_blank: true}
  validates :avatar, resizable_image: true

  before_validation :find_or_init_default_list, :find_or_init_default_contact_group

  def find_or_init_default_list
    lists.find_or_initialize_by(default: true, created_by: owner, name: "My Lists")
  end

  def find_or_init_default_contact_group
    contact_groups.find_or_initialize_by(default: true, created_by: owner, name: "My Contacts")
  end

  def find_or_build_billing_address
    billing_address || build_billing_address
  end

  def create_default_list
    lists.find_or_create_by(name: "My Lists", default: true, created_by: owner)
  end

  # Email address used for Pay customers and receipts
  # Defaults to billing_email if defined, otherwise uses the workspace owner's email
  def email
    billing_email? ? billing_email : owner.email
  end

  def impersonal?
    !personal?
  end

  def personal_workspace_for?(user)
    personal? && owner_id == user.id
  end

  def owner?(user)
    owner_id == user.id
  end

  # An workspace can be transferred by the owner if it:
  # * Isn't a personal workspace
  # * Has more than one user in it
  def can_transfer?(user)
    impersonal? && owner?(user) && users.size >= 2
  end

  # Transfers ownership of the workspace to a user
  # The new owner is automatically granted admin access to allow editing of the workspace
  # Previous owner roles are unchanged
  def transfer_ownership(user_id)
    previous_owner = owner
    workspace_user = workspace_users.find_by!(user_id: user_id)
    user = workspace_user.user

    ApplicationRecord.transaction do
      workspace_user.update!(admin: true)
      update!(owner: user)

      # Add any additional logic for updating records here
    end

    # Notify the new owner of the change
    Workspace::OwnershipNotification.with(workspace: self, previous_owner: previous_owner.name).deliver_later(user)
  rescue
    false
  end

  # Uncomment this to add generic trials (without a card or plan)
  #
  # after_create :start_trial
  #
  # def start_trial(length: 14.days)
  #   trial_ends_at = length.from_now
  #   set_payment_processor :fake_processor, allow_fake: true
  #   payment_processor.subscribe(plan: Plan.free.fake_processor_id, trial_ends_at: trial_ends_at, ends_at: trial_ends_at)
  # end

  # If you need to create some associated records when an Workspace is created,
  # use a `with_tenant` block to change the current tenant temporarily
  #
  # after_create do
  #   ActsAsTenant.with_tenant(self) do
  #     association.create(name: "example")
  #   end
  # end

  private

  # Attributes to sync to the Stripe Customer
  def stripe_attributes(*args)
    {address: billing_address&.to_stripe}.compact
  end
end
