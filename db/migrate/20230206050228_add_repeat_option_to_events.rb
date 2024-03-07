class AddRepeatOptionToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :repeat, :string, default: "never"
    add_column :events, :repeat_until_date, :datetime
    add_column :events, :repeat_except_dates, :jsonb, default: []
  end
end
