# frozen_string_literal: true

require 'chartkick'
require 'simple_drilldown/routing'

module SimpleDrilldown
  class Engine < ::Rails::Engine
    isolate_namespace SimpleDrilldown
    config.autoload_paths << File.dirname(__dir__)

    initializer 'simple_drilldown.assets.precompile' do |app|
      app.config.try(:assets)&.precompile&.push('simple_drilldown/application.css', 'chartkick.js')
    end

    ActionDispatch::Routing::Mapper.include SimpleDrilldown::Routing
  end
end
