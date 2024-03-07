class AddIndexUniqueToLmdIdToCoupons < ActiveRecord::Migration[7.0]
  def change
    add_index :coupons, :lmd_id, unique: true, where: "lmd_id IS NOT NULL", name: "unique_not_null_lmd_id"
  end
end
