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
require "rails_helper"

RSpec.describe CouponImporter, type: :model do
  describe "associations" do
    it { should have_many(:coupons) }
  end

  describe "default scope" do
    it "should order by last_extracted_at" do
      coupon_importer1 = create(:coupon_importer, last_extracted_at: 1.day.ago)
      coupon_importer2 = create(:coupon_importer, last_extracted_at: 2.days.ago)
      coupon_importer3 = create(:coupon_importer, last_extracted_at: 3.days.ago)
      expect(CouponImporter.all).to eq([coupon_importer1, coupon_importer2, coupon_importer3])
    end
  end
end
