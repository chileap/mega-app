class AddPayloadAndStatusAndICalId < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :status, :string
    add_column :events, :i_cal_uid, :string
    add_column :events, :payload, :text

    add_index :events, [:account_id, :i_cal_uid], unique: true
  end
end
