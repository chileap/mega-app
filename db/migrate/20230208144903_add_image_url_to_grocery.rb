class AddImageUrlToGrocery < ActiveRecord::Migration[7.0]
  def change
    add_column :groceries, :image_url, :string
  end
end
