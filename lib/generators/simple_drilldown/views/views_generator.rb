# frozen_string_literal: true

module SimpleDrilldown
  class ViewsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../../', __dir__)

    def copy_drilldown_views_file
      directory 'app/views'
    end
  end
end
