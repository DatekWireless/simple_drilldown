# frozen_string_literal: true

require 'test_helper'

class UserDrilldownControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test 'should get index' do
    get user_drilldown_index_url
    assert_response :success
  end
end
