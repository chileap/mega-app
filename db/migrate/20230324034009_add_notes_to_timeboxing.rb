class AddNotesToTimeboxing < ActiveRecord::Migration[7.0]
  def change
    add_column :timeboxings, :notes, :text
  end
end
