class CreateCouponImporters < ActiveRecord::Migration[7.0]
  def change
    create_table :coupon_importers do |t|
      t.integer :coupons_count, default: 0

      t.datetime :last_extracted_at, null: true
      t.timestamps
    end
  end
end
