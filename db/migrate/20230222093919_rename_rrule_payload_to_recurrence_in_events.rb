class RenameRrulePayloadToRecurrenceInEvents < ActiveRecord::Migration[7.0]
  def up
    rename_column :events, :rrule_payload, :recurrence
    change_column :events, :recurrence, :text
  end

  def down
    change_column :events, :recurrence, :string
    rename_column :events, :recurrence, :rrule_payload
  end
end
