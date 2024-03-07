require "test_helper"

class WorkspacesControllerTest < ActionDispatch::IntegrationTest
  test "returns current user workspaces" do
    user = users(:one)
    get api_v1_workspaces_url, headers: {Authorization: "token #{user.api_tokens.first.token}"}
    assert_response :success
    assert_includes response.parsed_body.map { |t| t["name"] }, user.workspaces.first.name
  end
end
