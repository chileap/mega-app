# == Schema Information
#
# Table name: grocery_categories
#
#  id         :bigint           not null, primary key
#  name       :string
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_grocery_categories_on_slug  (slug) UNIQUE
#
class GroceryCategory < ApplicationRecord
  has_many :grocery_category_tags, dependent: :destroy
  has_many :groceries, through: :grocery_category_tags

  validates :name, presence: true, uniqueness: true

  def self.search(search)
    if search
      where("name LIKE ?", "%#{search}%")
    else
      all
    end
  end
end
