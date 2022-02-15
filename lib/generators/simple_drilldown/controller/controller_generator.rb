# frozen_string_literal: true

module SimpleDrilldown
  class ControllerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    def copy_drilldown_controller_file
      template 'drilldown_controller.rb.erb', "app/controllers/#{file_name}_drilldown_controller.rb"
      template 'drilldown_controller_test.rb.erb', "test/controllers/#{file_name}_drilldown_controller_test.rb"
      route "draw_drilldown :#{singular_name}"
    end
  end
end
