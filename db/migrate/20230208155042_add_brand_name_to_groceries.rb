class AddBrandNameToGroceries < ActiveRecord::Migration[7.0]
  def change
    add_column :groceries, :brand_name, :string

    Grocery.all.each do |grocery|
      next if grocery.payload.blank?
      brand_name = JSON.parse(grocery.payload)["brands"]

      grocery.update(brand_name: brand_name)
    end
  end
end
