# frozen_string_literal: true

require 'test_helper'

class AdvancedPostDrilldownControllerTest < ActionDispatch::IntegrationTest
  setup { @post = posts(:one) }

  test 'should get index' do
    get advanced_post_drilldown_url
    assert_response :success
    assert_select 'table#drilldown-summary-table > tbody > tr', count: 1
    assert_select 'table#drilldown-summary-table > tbody > tr > td', '2', response.body
  end

  def test_should_get_index_with_list
    get advanced_post_drilldown_url params: { search: { list: 1 } }
    assert_response :success
    assert_select 'table#drilldown-summary-table > tbody > tr', count: 2
    assert_select <<~CSS.squish, '2'
      table#drilldown-summary-table > tbody > tr > td
    CSS
    assert_select 'table#drilldown-summary-table > tbody > tr table#drilldown-records-All', count: 1
    assert_select <<~CSS.squish, count: 2
      table#drilldown-summary-table > tbody > tr table#drilldown-records-All > tbody > tr
    CSS
    assert_select <<~CSS.squish, 'Show'
      table#drilldown-summary-table > tbody > tr table#drilldown-records-All > tbody > tr:first-of-type > td
    CSS
    assert_select <<~CSS.squish, 'Show'
      table#drilldown-summary-table > tbody > tr table#drilldown-records-All > tbody > tr:nth-of-type(2) > td
    CSS
  end
end
