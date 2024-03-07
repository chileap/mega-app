class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.references :contact_group
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :website_url
      t.string :country_code
      t.string :phone_number

      t.timestamps
    end
  end
end
