class AddFlaggedAtToTask < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :flagged_at, :datetime
  end
end
