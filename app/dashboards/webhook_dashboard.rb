require "administrate/base_dashboard"

class WebhookDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    callback_url: Field::String,
    channel_id: Field::String,
    connected_account: Field::BelongsTo,
    created_by: Field::BelongsTo,
    expiration: Field::String,
    kind: Field::String,
    next_sync_token: Field::String,
    payload: Field::String.with_options(searchable: false),
    provider: Field::String,
    resource_id: Field::String,
    resource_uri: Field::String,
    workspace: Field::BelongsTo,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    callback_url
    channel_id
    connected_account
    provider
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    callback_url
    channel_id
    connected_account
    created_by
    expiration
    kind
    next_sync_token
    payload
    provider
    resource_id
    resource_uri
    workspace
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    callback_url
    channel_id
    connected_account
    created_by
    expiration
    kind
    next_sync_token
    payload
    provider
    resource_id
    resource_uri
    workspace
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how webhooks are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(webhook)
  #   "Webhook ##{webhook.id}"
  # end
end
