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
class Contact < ApplicationRecord
  belongs_to :workspace
  belongs_to :created_by, class_name: "User"
  belongs_to :contact_group, counter_cache: true

  # validates :name, presence: true

  validate :website_url_must_be_valid

  before_validation :set_name

  def link_website_url
    return nil if website_url.blank?
    if website_url.start_with?("http://", "https://")
      website_url
    else
      "http://#{website_url}"
    end
  end

  def set_name
    self.name = if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    elsif first_name.present?
      first_name
    elsif last_name.present?
      last_name
    else
      "No Name"
    end
  end

  def self.filter_by(params)
    contacts = all
    workspace = contacts.first.workspace if contacts.any?
    if params[:contact_group_id].present?
      contacts = contacts.where(contact_group_id: params[:contact_group_id])
    elsif workspace
      contacts = contacts.where(contact_group_id: workspace.default_contact_group.id)
    end
    contacts = contacts.where("name LIKE ?", "%#{params[:keyword]}%") if params[:keyword]
    contacts
  end

  private

  def website_url_must_be_valid
    return if website_url.blank?
    unless PublicSuffix.valid?(website_url)
      errors.add(:website_url, "is not a valid URL")
    end
  end
end
