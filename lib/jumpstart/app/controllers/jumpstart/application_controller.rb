module Jumpstart
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    layout "jumpstart/application"

    include Users::TimeZone

    impersonates :user

    # Used for sharing flash between main app and gem
    def current_workspace
    end
    helper_method :current_workspace
  end
end
