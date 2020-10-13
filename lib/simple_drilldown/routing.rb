# frozen_string_literal: true

module SimpleDrilldown
  # Routing helper methods
  module Routing
    def draw_drilldown(path, controller = nil)
      path = "#{path}_drilldown" unless /_drilldown$/.match?(path)
      controller ||= path
      get "#{path}(.:format)" => "#{controller}#index", as: path
      scope path, as: path do
        %i[choices excel_export excel_export_records html_export index].each do |action|
          get "#{action}(/:id)(.:format)", controller: controller, action: action, as: action
        end
      end
    end
  end
end
