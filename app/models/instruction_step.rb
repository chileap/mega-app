# == Schema Information
#
# Table name: instruction_steps
#
#  id               :bigint           not null, primary key
#  description      :text
#  full_description :text
#  position         :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  meal_id          :bigint           not null
#
# Indexes
#
#  index_instruction_steps_on_meal_id  (meal_id)
#
# Foreign Keys
#
#  fk_rails_...  (meal_id => meals.id)
#
class InstructionStep < ApplicationRecord
  belongs_to :meal

  validates :position, presence: true
  validates :description, presence: true
end
