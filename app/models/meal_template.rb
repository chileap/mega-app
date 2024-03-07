# == Schema Information
#
# Table name: meal_templates
#
#  id                         :bigint           not null, primary key
#  cook_time                  :integer
#  description                :text
#  ingredient_templates_count :integer          default(0)
#  meals_count                :integer          default(0)
#  name                       :string           not null
#  payload                    :text
#  prep_time                  :integer
#  serving_for                :integer          default(2)
#  total_time                 :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
class MealTemplate < ApplicationRecord
  has_many :meals, dependent: :nullify
  has_many :ingredient_templates, dependent: :destroy
  has_many :groceries, through: :ingredient_templates
  has_many :instruction_template_steps, dependent: :destroy
  has_many :favorite_meal_templates, dependent: :destroy

  validates :name, presence: true, uniqueness: {scope: :serving_for, case_sensitive: false}

  accepts_nested_attributes_for :ingredient_templates, allow_destroy: true
  accepts_nested_attributes_for :instruction_template_steps, allow_destroy: true

  def openai_response
    payload.is_a?(String) ? JSON.parse(payload) : payload
  end

  def self.filter_by(query)
    return all unless query.present?

    where("name ILIKE ?", "%#{query}%")
  end

  def is_user_favorite?(user, workspace)
    favorite_meal_templates.where(user: user, workspace: workspace).any?
  end
end
