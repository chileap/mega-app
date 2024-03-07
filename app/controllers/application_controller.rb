class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include BundleAssets
  include SetCurrentRequestDetails
  include SetLocale
  include Jumpstart::Controller
  include Workspaces::SubscriptionStatus
  include Users::NavbarNotifications
  include Users::Sudo
  include Users::TimeZone
  include Pagy::Backend
  include CurrentHelper
  include Sortable
  include DeviceFormat
  include Users::AgreementUpdates
  include Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?

  impersonates :user

  def current_controller?(names)
    return false if params[:controller].blank?
    names.include?(params[:controller])
  end

  around_action :switch_time_zone, if: :current_user

  def switch_time_zone(&block)
    if current_user.time_zone.present? && ActiveSupport::TimeZone[current_user.time_zone].present?
      Time.use_zone(current_user.time_zone, &block)
    else
      current_user.update(time_zone: cookies[:browser_time_zone]) if cookies[:browser_time_zone].present?
      Time.use_zone(cookies[:browser_time_zone], &block)
    end
  end

  helper_method :current_controller?

  def redirect_to_back(options = {})
    uri = URI(request.referer)
    uri.query = options.delete(:params)&.to_query
    uri.fragment = options.delete(:anchor)

    redirect_to(uri.to_s, options)
  end

  protected

  # To add extra fields to Devise registration, add the attribute names to `extra_keys`
  def configure_permitted_parameters
    extra_keys = [:avatar, :name, :time_zone, :preferred_language]
    signup_keys = extra_keys + [:terms_of_service, :invite, owned_workspaces_attributes: [:name]]
    devise_parameter_sanitizer.permit(:sign_up, keys: signup_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: extra_keys)
    devise_parameter_sanitizer.permit(:accept_invitation, keys: extra_keys)
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

  # Helper method for verifying authentication in a before_action, but redirecting to sign up instead of login
  def authenticate_user_with_sign_up!
    unless user_signed_in?
      store_location_for(:user, request.fullpath)
      redirect_to new_user_registration_path, alert: t("create_an_account_first")
    end
  end

  def require_current_workspace_admin
    unless current_workspace_admin?
      redirect_to root_path, alert: t("must_be_an_admin")
    end
  end

  private

  def require_workspace
    redirect_to new_user_registration_path unless current_workspace
  end
end
