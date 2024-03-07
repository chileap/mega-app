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
class CouponImporter < ApplicationRecord
  has_many :coupons, dependent: :destroy

  default_scope { order(last_extracted_at: :desc) }
end
