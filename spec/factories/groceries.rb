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
FactoryBot.define do
  factory :grocery do
    name { Faker::Name.unique }
    brand_name { Faker::Name.unique }
  end
end
