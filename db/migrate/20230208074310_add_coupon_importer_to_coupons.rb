class AddCouponImporterToCoupons < ActiveRecord::Migration[7.0]
  def change
    add_reference :coupons, :coupon_importer, null: true, foreign_key: true

    coupon_importer = CouponImporter.find_or_create_by(
      last_extracted_at: Time.zone.now.beginning_of_day
    )
    Coupon.update_all(coupon_importer_id: coupon_importer.id)
  end
end
