module Jumpstart
  module ApplicationHelper
    include Pagy::Frontend

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
      ActiveSupport::TimeZone.all.find { |tz| tz.name == name }
    end
  end
end
