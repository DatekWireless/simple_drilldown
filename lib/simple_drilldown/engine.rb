# frozen_string_literal: true

module SimpleDrilldown
  class Engine < ::Rails::Engine
    isolate_namespace SimpleDrilldown

    initializer 'simple_drilldown.assets.precompile' do |app|
      app.config.assets.precompile += %w[chartkick.js]
    end
  end
end
