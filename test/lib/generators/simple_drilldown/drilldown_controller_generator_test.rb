# frozen_string_literal: true

require 'test_helper'
require 'generators/simple_drilldown/controller/controller_generator'

module SimpleDrilldown
  class DrilldownControllerGeneratorTest < Rails::Generators::TestCase
    tests ControllerGenerator
    destination Rails.root.join('tmp/generators')
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
