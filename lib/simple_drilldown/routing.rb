# frozen_string_literal: true

module SimpleDrilldown
  # Routing helper methods
  module Routing
    def draw_drilldown(path, controller = path)
      get "#{path}(.:format)" => "#{controller}#index", as: path
      scope path do
        %i[excel_export html_export index].each do |action|
          get "#{action}(/:id)(.:format)", controller: controller, action: action
        end
      end
    end
  end
end
