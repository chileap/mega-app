module ApplicationHelper
  include Pagy::Frontend

  def user_settings_nav_link_to
    ["users/preferences", "account/passwords", "users/connected_accounts", "users/notifications", "subscriptions", "workspaces", "api_tokens", "users/registrations", "billing_addresses"]
  end

  def format_date(date)
    if date.to_date == Date.today
      "Today"
    elsif date.to_date == Date.yesterday
      "Yesterday"
    elsif date.to_date == Date.tomorrow
      "Tomorrow"
    else
      date.strftime("%B %d, %Y")
    end
  end

  def timezone_options
    ActiveSupport::TimeZone.all.uniq { |p| p.utc_offset }
  end

  def find_selected_timezone_option(time_zone)
    timezone_options.find { |tz| tz.utc_offset == time_zone.utc_offset }
  end

  def duplicated_timezone_options(current_option)
    ActiveSupport::TimeZone.all.select { |tz| tz.utc_offset == current_option.utc_offset }.map(&:name).join(", ")
  end

  def find_timezone_by_name(name)
    timezone = ActiveSupport::TimeZone.all.find { |tz| tz.name == name }
    timezone || ActiveSupport::TimeZone.all.find { |tz| tz.tzinfo.name == name }
  end

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flash", partial: "shared/flash"
  end

  def classes_for_flash(flash_type)
    case flash_type.to_sym
    when :error
      "bg-red-100 text-red-700"
    else
      "bg-blue-100 text-blue-700"
    end
  end

  # Generates button tags for Turbo disable with
  # Preserve opacity-25 opacity-75 during purge
  def button_text(text = nil, disable_with: t("processing"), &block)
    text = capture(&block) if block

    tag.span(text, class: "when-enabled") +
      tag.span(class: "when-disabled") do
        render_svg("icons/spinner", styles: "animate-spin inline-block h-4 w-4 mr-2") + disable_with
      end
  end

  def disable_with(text)
    "<i class=\"far fa-spinner-third fa-spin\"></i> #{text}".html_safe
  end

  def render_svg(name, options = {})
    options[:title] ||= name.underscore.humanize
    options[:aria] = true
    options[:nocomment] = true
    options[:class] = options.fetch(:styles, "fill-current text-gray-500")

    filename = "#{name}.svg"
    inline_svg_tag(filename, options)
  end

  # fa_icon "thumbs-up", weight: "fa-solid"
  # <i class="fa-solid fa-thumbs-up"></i>
  def fa_icon(name, options = {})
    weight = options.delete(:weight) || "fa-regular"
    options[:class] = [weight, "fa-#{name}", options.delete(:class)]
    tag.i(nil, **options)
  end

  def badge(text, options = {})
    base = options.delete(:base) || "rounded py-0.5 px-2 text-xs inline-block font-semibold leading-normal mr-2"
    color = options.delete(:color) || "bg-gray-100 text-gray-800"
    options[:class] = Array.wrap(options[:class]) + [base, color]
    tag.div(text, **options)
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def viewport_meta_tag(content: "width=device-width, initial-scale=1", turbo_native: "maximum-scale=1.0, user-scalable=0")
    full_content = [content, (turbo_native if turbo_native_app?)].compact.join(", ")
    tag.meta name: "viewport", content: full_content
  end

  def first_page?
    @pagy.page == 1
  end

  # Unification of
  # {Administrate::ApplicationController#existing_action? existing_action?}
  # and
  # {Administrate::ApplicationController#authorized_action?
  # authorized_action?}
  #
  # @param target [ActiveRecord::Base, Class, Symbol, String] A resource,
  #   a class of resources, or the name of a class of resources.
  # @param action_name [String, Symbol] The name of an action that might be
  #   possible to perform on a resource or resource class.
  # @return [Boolean] Whether the action both (a) exists for the record class,
  #   and (b) the current user is authorized to perform it on the record
  #   instance or class.
  def accessible_action?(target, action_name)
    target = target.to_sym if target.is_a?(String)
    target_class_or_class_name =
      target.is_a?(ActiveRecord::Base) ? target.class : target

    existing_action?(target_class_or_class_name, action_name)
  end
end
