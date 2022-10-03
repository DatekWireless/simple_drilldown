# frozen_string_literal: true

require 'test_helper'
require 'simple_drilldown/helper'

module SimpleDrilldown
  class HelperTest < ActiveSupport::TestCase
    include Helper

    test 'subcaption blank' do
      @search = Search.new({})
      assert_equal 'Application Record Count', caption
      assert_equal '', subcaption
    end

    test 'subcaption with filter text' do
      @search = Search.new({})
      @filter_text = 'Subcaption'
      assert_equal 'Application Record Count', caption
      assert_equal 'for Subcaption', subcaption
    end

    test 'subcaption with title and filter text' do
      @search = Search.new({ title: 'My Title' })
      @filter_text = 'Subcaption'
      assert_equal 'My Title', caption
      assert_equal '', subcaption
    end

    private

    def controller
      return @controller if @controller

      Controller.target_class ::ApplicationRecord
      @controller = Controller.new
    end
  end
end
