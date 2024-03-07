class AddTimeboxingItemsCountAndRemovePriorityTaskIdsToTimeboxing < ActiveRecord::Migration[7.0]
  def change
    add_column :timeboxings, :timeboxing_items_count, :integer, null: false, default: 0
    remove_column :timeboxings, :priority_task_ids
  end
end
