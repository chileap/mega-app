class AddMoreFieldToCoupons < ActiveRecord::Migration[7.0]
  def change
    add_column :coupons, :lmd_id, :string
    add_column :coupons, :status, :string
    add_column :coupons, :offer_text, :text
    add_column :coupons, :title, :string
    add_column :coupons, :type, :string
    add_column :coupons, :offer_value, :string
    add_column :coupons, :offer_type, :string
    add_column :coupons, :store, :string
    add_column :coupons, :categories, :text
    add_column :coupons, :image_url, :string
    add_column :coupons, :url, :string
    add_column :coupons, :smart_link, :string
    add_column :coupons, :publisher_exclusive, :string
    add_column :coupons, :merchant_homepage, :string
    add_column :coupons, :category_array, :jsonb
    add_column :coupons, :terms_and_conditions, :string

    remove_column :coupons, :price, :float
    remove_column :coupons, :unit, :integer
  end
end
