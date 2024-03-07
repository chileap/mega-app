# == Schema Information
#
# Table name: instruction_template_steps
#
#  id               :bigint           not null, primary key
#  description      :text
#  full_description :text
#  position         :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  meal_template_id :bigint           not null
#
# Indexes
#
#  index_instruction_template_steps_on_meal_template_id  (meal_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (meal_template_id => meal_templates.id)
#
FactoryBot.define do
  factory :instruction_template_step do
  end
end
