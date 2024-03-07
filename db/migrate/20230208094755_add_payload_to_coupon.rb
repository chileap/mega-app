class AddPayloadToCoupon < ActiveRecord::Migration[7.0]
  def change
    add_column :coupons, :payload, :jsonb, default: {}
  end
end
