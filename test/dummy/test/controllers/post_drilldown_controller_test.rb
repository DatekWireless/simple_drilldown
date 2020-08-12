# frozen_string_literal: true

require 'test_helper'

class PostDrilldownControllerTest < ActionDispatch::IntegrationTest
  setup { @post = posts(:one) }

  test 'should get index' do
    get post_drilldown_index_url
    assert_response :success
  end

  def test_should_get_index_with_list
    get post_drilldown_index_url search: { list: 1 }
    assert_response :success
  end
end
