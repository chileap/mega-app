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

class User::ConnectedAccount < ApplicationRecord
  serialize :auth, JSON

  encrypts :access_token
  encrypts :access_token_secret
  encrypts :app_specific_password

  enum :provider_names, {
    google_oauth2: "Google",
    apple: "Apple",
    microsoft_graph: "Microsoft",
    github: "GitHub",
    facebook: "Facebook",
    twitter: "Twitter",
    yahoo: "Yahoo"
  }

  # Associations
  belongs_to :user
  belongs_to :workspace, optional: true
  has_one :webhook, foreign_key: "connected_account_id", dependent: :destroy

  validate :apple_provider_credential, if: -> { provider.present? && provider == "apple" }
  validate :yahoo_provider_credential, if: -> { provider.present? && provider == "yahoo" }

  # Helper scopes for each provider
  Devise.omniauth_configs.each do |provider, _|
    scope provider, -> { where(provider: provider) }
  end

  # Look up from provider name
  def self.for_omniauth(provider)
    where(provider: provider).first
  end

  # Look up from Omniauth auth hash
  def self.for_auth(auth)
    where(provider: auth.provider, uid: auth.uid).first
  end

  def google_oauth2?
    provider == "google_oauth2"
  end

  def apple?
    provider == "apple"
  end

  def microsoft_graph?
    provider == "microsoft_graph"
  end

  def yahoo?
    provider == "yahoo"
  end

  def google_webhook
    webhooks.with_provider(:google_oauth2).first
  end

  def microsoft_webhook
    webhooks.with_provider(:microsoft_graph).first
  end

  # Use this method to retrieve the latest access_token.
  # Token will be automatically renewed as necessary
  def token
    renew_token! if expired?
    access_token
  end

  # Tokens that expire very soon should be consider expired
  def expired?
    expires_at? && expires_at <= 30.minutes.from_now
  end

  # Force a renewal of the access token
  def renew_token!
    new_token = current_token.refresh!
    update(
      access_token: new_token.token,
      refresh_token: new_token.refresh_token,
      expires_at: Time.at(new_token.expires_at)
    )
  end

  def name
    auth&.dig("info", "name")
  end

  def user_email
    auth&.dig("info", "email")
  end

  def image_url
    auth&.dig("info", "image") || GravatarHelper.gravatar_url_for(email)
  end

  def apple_provider_credential
    client = AppleClient.new(self).client

    if client.nil?
      errors.add(:email, "Credentials Mismatch. Please Provide Valid Credentials")
    end
  end

  def yahoo_provider_credential
    client = YahooClient.new(self).client

    if client.nil?
      errors.add(:email, "Credentials Mismatch. Please Provide Valid Credentials")
    end
  end

  def create_google_webhook(response, next_sync_token)
    webhooks.create(
      resource_id: response.resource_id,
      expiration: response.expiration,
      channel_id: response.id,
      kind: response.kind,
      resource_uri: response.resource_uri,
      next_sync_token: next_sync_token,
      created_by: user
    )
  end

  def update_google_webhook(response, next_sync_token)
    webhooks.update(
      expiration: response.expiration,
      channel_id: response.id,
      kind: response.kind,
      resource_uri: response.resource_uri,
      next_sync_token: next_sync_token
    )
  end

  private

  def current_token
    OAuth2::AccessToken.new(
      strategy.client,
      access_token,
      refresh_token: refresh_token
    )
  end

  def strategy
    # First check the Jumpstart providers for credentials
    provider_config = Jumpstart::Omniauth.enabled_providers[provider.to_sym]

    # Fallback to the Rails credentials
    provider_config ||= Rails.application.credentials.dig(:omniauth, provider.to_sym)

    OmniAuth::Strategies.const_get(OmniAuth::Utils.camelize(provider).to_s).new(
      nil,
      provider_config[:public_key], # client id
      provider_config[:private_key] # client secret
    )
  end
end
