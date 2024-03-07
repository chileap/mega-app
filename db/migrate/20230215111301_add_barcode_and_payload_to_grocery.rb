class AddBarcodeAndPayloadToGrocery < ActiveRecord::Migration[7.0]
  def change
    add_column :groceries, :barcode, :string
    add_column :groceries, :payload, :jsonb
  end
end
