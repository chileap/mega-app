require "administrate/base_dashboard"

class MealTemplateDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    cook_time: Field::Number,
    description: Field::Text,
    groceries: Field::HasMany,
    ingredient_templates: Field::HasMany.with_options(limit: 20),
    ingredient_templates_count: Field::Number,
    instruction_template_steps: Field::HasMany.with_options(limit: 20),
    meals: Field::HasMany,
    meals_count: Field::Number,
    name: Field::String,
    payload: Field::Text,
    prep_time: Field::Number,
    serving_for: Field::Number,
    total_time: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    name
    groceries
    meals_count
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    serving_for
    description
    ingredient_templates
    instruction_template_steps
    prep_time
    cook_time
    total_time
    meals_count
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    name
    serving_for
    description
    cook_time
    prep_time
    total_time
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

  # Overwrite this method to customize how meal templates are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(meal_template)
    meal_template.name
  end
end
