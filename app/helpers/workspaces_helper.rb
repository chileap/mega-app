module WorkspacesHelper
  def workspace_avatar(workspace, options = {})
    size = options[:size] || 48
    classes = options[:class]

    if workspace.personal? && workspace.owner_id == current_user&.id
      image_tag(
        avatar_url_for(workspace.users.first, options),
        class: classes,
        alt: workspace.name
      )

    elsif workspace.avatar.attached? && workspace.avatar.variable?
      image_tag(
        workspace.avatar.variant(resize_to_fit: [size, size]),
        class: classes,
        alt: workspace.name
      )
    else
      content = tag.span(workspace.name.to_s.first, class: "initials")

      if options[:include_user]
        content += image_tag(avatar_url_for(current_user), class: "avatar-small")
      end

      tag.span(content, class: "avatar bg-blue-500 #{classes}")
    end
  end

  def workspace_user_roles(workspace, workspace_user)
    roles = []
    roles << "Owner" if workspace_user.respond_to?(:user_id) && workspace.owner_id == workspace_user.user_id
    WorkspaceUser::ROLES.each do |role|
      roles << role.to_s.humanize if workspace_user.public_send(:"#{role}?")
    end
    roles
  end

  def workspace_admin?(workspace, workspace_user)
    WorkspaceUser.find_by(workspace: workspace, user: workspace_user).admin?
  end

  # A link to switch the workspace
  #
  # For session switching, we'll use a button_to and submit to the server
  # For path switching, we'll link to the path
  # For subdomains, we can simply link to the subdomain
  # For domains, we can link to the domain (assuming it's configured correctly)
  #
  # The button/link label defaults to the workspace name, can be overriden with either:
  #   * options[:label]
  #   * Ruby block
  def switch_workspace_button(workspace, **options, &block)
    if block
      # if Jumpstart::Multitenancy.domain? && workspace.domain?
      #   link_to options.fetch(:label, workspace.name), workspace.domain, options, &block
      if Jumpstart::Multitenancy.subdomain? && workspace.subdomain?
        link_to root_url(subdomain: workspace.subdomain), options, &block
      elsif Jumpstart::Multitenancy.path?
        link_to root_url(script_name: "/#{workspace.id}"), options, &block
      else
        button_to switch_workspace_path(workspace), options.merge(method: :patch), &block
      end
    # elsif Jumpstart::Multitenancy.domain? && workspace.domain?
    #   link_to options.fetch(:label, workspace.name), workspace.domain, options
    elsif Jumpstart::Multitenancy.subdomain? && workspace.subdomain?
      link_to options.fetch(:label, workspace.name), root_url(subdomain: workspace.subdomain), options
    elsif Jumpstart::Multitenancy.path?
      link_to options.fetch(:label, workspace.name), root_url(script_name: "/#{workspace.id}"), options
    else
      button_to options.fetch(:label, workspace.name), switch_workspace_path(workspace), options.merge(method: :patch)
    end
  end
end
