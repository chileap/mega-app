class AddCreatedByAndAccountToContact < ActiveRecord::Migration[7.0]
  def change
    add_reference :contacts, :account, null: false, foreign_key: true
    add_reference :contacts, :created_by, foreign_key: {to_table: :users}, null: false

    Contact.all.find_each do |contact|
      contact.account = contact.contact_group.account
      contact.created_by = contact.contact_group.created_by
      contact.save!
    end
  end
end
