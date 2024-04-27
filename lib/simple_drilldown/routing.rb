# frozen_string_literal: true

module SimpleDrilldown
  # Routing helper methods
  module Routing
    def draw_drilldown(path, controller = nil)
      path = "#{path}_drilldown" unless /_drilldown$/.match?(path)
      controller ||= path
      get "#{path}(.:format)" => "#{controller}#index", as: path
      scope path, controller:, as: path do
        { excel_export: :xlsx, excel_export_records: :xlsx, html_export: :html }.each do |action, format|
          get action, defaults: { format: }
        end
        get 'choices/:dimension_name', action: :choices, as: :choices
        yield if block_given?
      end
    end
  end
end
