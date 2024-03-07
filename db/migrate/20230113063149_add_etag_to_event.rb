class AddEtagToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :etag, :string
    add_column :events, :event_url, :string
  end
end
