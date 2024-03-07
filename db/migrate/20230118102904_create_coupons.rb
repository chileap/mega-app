class CreateCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :coupons do |t|
      t.float :price
      t.text :description
      t.datetime :valid_from
      t.datetime :valid_to
      t.integer :unit
      t.string :coupon_code
      t.references :grocery, null: false, foreign_key: true

      t.timestamps
    end
  end
end
