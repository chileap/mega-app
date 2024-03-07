class AddDefaultSourceTypeInEvent < ActiveRecord::Migration[7.0]
  def change
    change_column :events, :source_type, :string, default: "default"
  end
end
