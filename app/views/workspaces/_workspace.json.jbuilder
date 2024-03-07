json.cache! [workspace] do
  json.extract! workspace, :id, :name, :personal, :owner_id, :created_at, :updated_at
  json.workspace_users do
    json.array! workspace.workspace_users, :id, :user_id
  end
end
