class AddCompanyNameToContacts < ActiveRecord::Migration[7.0]
  def change
    add_column :contacts, :company_name, :string
  end
end
