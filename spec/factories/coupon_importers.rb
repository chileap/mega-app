# == Schema Information
#
# Table name: coupon_importers
#
#  id                :bigint           not null, primary key
#  coupons_count     :integer          default(0)
#  last_extracted_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
FactoryBot.define do
  factory :coupon_importer do
  end
end
