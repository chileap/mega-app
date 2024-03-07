# == Schema Information
#
# Table name: groceries
#
#  id         :bigint           not null, primary key
#  barcode    :string
#  brand_name :string
#  image_data :text
#  image_url  :string
#  name       :string
#  notes      :text
#  payload    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Grocery < ApplicationRecord
  has_many :ingredients, dependent: :destroy
  has_many :meals, through: :ingredients
  has_many :ingredient_templates, dependent: :destroy
  has_many :meal_templates, through: :ingredient_templates
  has_many :grocery_category_tags, dependent: :destroy
  has_many :grocery_categories, through: :grocery_category_tags

  has_one_attached :image

  validates :name, presence: true, uniqueness: true

  accepts_nested_attributes_for :grocery_categories, reject_if: ->(attributes) { attributes["name"].blank? }, allow_destroy: true

  before_validation do
    if grocery_categories.blank?
      category = GroceryCategory.find_or_create_by(name: "Other")
      self.grocery_categories = [category]
    end
  end

  def self.search(search)
    if search
      where("lower(name) LIKE ?", "%#{search.downcase}%")
    else
      all
    end
  end

  def category_name
    grocery_categories.pluck(:name).join(", ")
  end
end
