class AddListIdToTasks < ActiveRecord::Migration[7.0]
  def change
    add_reference :tasks, :list

    # add default list into account and list
    reversible do |dir|
      dir.up do
        if ActiveRecord::Base.connection.table_exists?("lists") && ActiveRecord::Base.connection.table_exists?("workspaces")
          Workspace.find_each do |account|
            list = account.lists.find_or_create_by!(
              name: "My List",
              default: true,
              created_by: account.owner
            )
            account.tasks.update_all(list_id: list.id)
          end
        end
      end
      dir.down do
        puts "Removed default list"
        Workspace.find_each do |account|
          list = account.lists.find_by(
            name: "My List",
            default: true,
            created_by: account.owner
          )
          account.tasks.update_all(list_id: nil)
          list.destroy if list.present?
        end
        puts "Removed succeeded"
      end
    end
  end
end
