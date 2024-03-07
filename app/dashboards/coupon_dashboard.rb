require "administrate/base_dashboard"

class CouponDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    lmd_id: Field::String,
    title: Field::String,
    description: Field::Text,
    categories: Field::Text,
    category_array: ArrayField,
    offer_text: Field::Text,
    offer_type: Field::String,
    offer_value: Field::String,
    type: Field::String,
    coupon_code: Field::String,
    valid_from: Field::DateTime,
    valid_to: Field::DateTime,
    valid_dates: Field::String,
    payload: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    lmd_id
    title
    categories
    valid_dates
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    title
    description
    categories
    offer_text
    offer_type
    type
    offer_value
    coupon_code
    valid_from
    valid_to
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    title
    description
    offer_text
    type
    valid_from
    valid_to
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

  # Overwrite this method to customize how coupons are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(coupon)
    coupon.title
  end
end
