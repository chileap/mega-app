source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.0.4.3"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails", ">= 3.4.1"

# Use postgresql as the database for Active Record
gem "pg"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.2"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 1.4"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "~> 1.0", ">= 1.0.2"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder", github: "excid3/jbuilder", branch: "partial-paths" # "~> 2.11"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 5.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.12"

# Security update
gem "nokogiri", ">= 1.12.5"

group :development, :test do
  # Start debugger with binding.b [https://github.com/ruby/debug]
  gem "debug", ">= 1.0.0", platforms: %i[mri mingw x64_mingw]

  # Optional other debugging tools
  # gem "byebug", platforms: [:mri, :mingw, :x64_mingw]

  gem "annotate", github: "excid3/annotate_models", branch: "rails7"
  gem "erb_lint", require: false
  gem "factory_bot_rails", "~> 6.2"
  gem "faker", "~> 3.2"
  gem "letter_opener_web", "~> 2.0"
  gem "rspec-rails", "~> 6.0.0"
  gem "standard", require: false
  gem "pry"

  gem "database_cleaner-active_record"

  # Security tooling to
  # gem "brakeman"
  # gem "bundler-audit", github: "rubysec/bundler-audit"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", ">= 4.1.0"

  # A fully configurable and extendable Git hook manager
  gem "overcommit", require: false

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler", ">= 2.3.3"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "bullet"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "~> 3.40"
  gem "selenium-webdriver", "~> 4.18", ">= 4.18.1"
  gem "shoulda-matchers", "~> 5.3"
  gem "webmock"
end

# Jumpstart dependencies
gem "jumpstart", path: "lib/jumpstart", group: :omit

gem "acts_as_tenant", "~> 0.6"
gem "administrate", github: "excid3/administrate", branch: "jumpstart" # '~> 0.10.0'
gem "administrate-field-active_storage", "~> 0.4.2"
gem "country_select", "~> 8.0"
gem "cssbundling-rails", "~> 1.1.0"
gem "devise", "~> 4.8", ">= 4.8.1"
gem "devise-i18n", "~> 1.10"
gem "inline_svg", "~> 1.9"
gem "invisible_captcha", "~> 2.1"
gem "jsbundling-rails", "~> 1.1.0"
gem "local_time", "~> 2.1"
gem "name_of_person", "~> 1.0"
gem "noticed", "~> 1.5"
gem "oj", "~> 3.14"
gem "omniauth", "~> 2.1"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "pagy", "~> 6.0"
gem "pay", "~> 6.3.1"
gem "pg_search", "~> 2.3"
gem "prawn", github: "prawnpdf/prawn"
gem "prefixed_ids", "~> 1.5"
gem "pretender", "~> 0.4.0"
gem "pundit", "~> 2.1"
gem "receipts", "~> 2.2"
gem "responders", github: "excid3/responders", branch: "fix-redirect-status-config"
gem "rotp", "~> 6.2"
gem "rqrcode", "~> 2.1"
gem "ruby-oembed", "~> 0.16.0", require: "oembed"
gem "view_component", "~> 2.80"
gem "enumerize"
gem "icalendar", "~> 2.8"
gem "google-api-client", require: "google/apis/calendar_v3"
gem "calendav", "~> 0.4.0"
gem "ruby-openai"
gem "public_suffix"
gem "simple_form", "~> 5.2"
gem "faraday", "~> 2.7"
gem "user_preferences", "~> 1.0", ">= 1.0.2"
# Jumpstart manages a few gems for us, so install them from the extra Gemfile
eval_gemfile "config/jumpstart/Gemfile" if File.exist?("config/jumpstart/Gemfile")

# We recommend using strong migrations when your app is in production
# gem "strong_migrations", "~> 0.7.6"
