# frozen_string_literal: true

class DrilldownControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def copy_drilldown_controller_file
    template 'drilldown_controller.rb.erb', "app/controllers/#{file_name}_drilldown_controller.rb"
    route "resources(:#{singular_name}_drilldown, only: :index){collection{get :excel_export;get :html_export}}"
  end
end
