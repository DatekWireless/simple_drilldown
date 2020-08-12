# frozen_string_literal: true

require 'chartkick'

module SimpleDrilldown
  class Engine < ::Rails::Engine
    isolate_namespace SimpleDrilldown
    config.autoload_paths << File.dirname(__dir__)

    initializer 'simple_drilldown.assets.precompile' do |app|
      app.config.assets.precompile += %w[chartkick.js]
    end
  end
end
