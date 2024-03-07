class AddRrulePayloadAndRepeatCountToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :rrule_payload, :string
    add_column :events, :repeat_count, :integer
  end
end
