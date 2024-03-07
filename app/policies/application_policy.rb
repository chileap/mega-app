# frozen_string_literal: true

class ApplicationPolicy
  # We use WorkspaceUser for policies because it contains roles for the current workspace
  # This allows separate roles for each user and workspace.
  #
  # Defaults:
  # - Allow admins
  # - Deny everyone else

  attr_reader :workspace_user, :record

  def initialize(workspace_user, record)
    # Comment out to allow guest users
    raise Pundit::NotAuthorizedError, "must be logged in" unless workspace_user

    @workspace_user = workspace_user
    @record = record
  end

  def index?
    workspace_user.admin?
  end

  def show?
    workspace_user.admin?
  end

  def create?
    workspace_user.admin?
  end

  def new?
    create?
  end

  def update?
    workspace_user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    workspace_user.admin?
  end

  class Scope
    def initialize(workspace_user, scope)
      # Comment out to allow guest users
      raise Pundit::NotAuthorizedError, "must be logged in" unless workspace_user

      @workspace_user = workspace_user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :workspace_user, :scope
  end
end
