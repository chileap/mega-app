require "test_helper"

Dir["#{File.dirname(__FILE__)}/support/system/**/*.rb"].sort.each { |f| require f }

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: ENV.fetch("DRIVER", :headless_chrome).to_sym, screen_size: [1400, 1400]

  Selenium::WebDriver.logger.level = :info

  include Warden::Test::Helpers
  include StripeSystemTestHelper
  include TrixSystemTestHelper

  def switch_workspace(workspace)
    visit test_switch_workspace_url(workspace)
  end
end

Capybara.default_max_wait_time = 10

# Add a route for easily switching workspaces in system tests
Rails.application.routes.append do
  get "/workspaces/:id/switch", to: "workspaces#switch", as: :test_switch_workspace
end
Rails.application.reload_routes!
