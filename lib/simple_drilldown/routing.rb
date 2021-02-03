# frozen_string_literal: true

module SimpleDrilldown
  # Routing helper methods
  module Routing
    def draw_drilldown(path, controller = nil)
      path = "#{path}_drilldown" unless /_drilldown$/.match?(path)
      controller ||= path
      get "#{path}(.:format)" => "#{controller}#index", as: path
      scope path, controller: controller, as: path do
        %i[excel_export excel_export_records html_export].each { |action| get action }
        get "choices/:dimension_name", action: :choices, as: :choices
      end
    end
  end
end
