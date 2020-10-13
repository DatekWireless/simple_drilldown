# frozen_string_literal: true

require 'test_helper'

class UserDrilldownControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test 'should get index' do
    get user_drilldown_index_url
    assert_response :success
  end

    # { :value => 'All', :count => 3, :volume => 22, :volume_compensated => 23}
  def test_index_with_no_dimension
    get user_drilldown_index_path, params: { search: { filter: { calendar_date: %w[2009-01-01
                                                                                          2009-03-30] } } }
    assert_response :success
  end

  # { :value => 'All', :count => 2, :volume => 44, :volume_compensated => 46,
  #   :rows => [
  #     { :value => '2008', :count => 1, :volume => 22, :volume_compensated => 23},
  #     { :value => '2009', :count => 1, :volume => 22, :volume_compensated => 23},
  #   ]
  # }
  def test_index_with_1_dimension
    get user_drilldown_index_path, params: { search: { dimensions: ['year'],
                                                              filter: { calendar_date: %w[2009-01-01
                                                                                          2009-03-30] } } }
    assert_response :success
  end

  # { :value => 'All', :count => 4, :volume => 88, :volume_compensated => 92,
  #   :rows => [
  #     { :value => '2008', :count => 2, :volume => 44, :volume_compensated => 46,
  #       :rows => [
  #         { :value => '1', :count => 1, :volume => 22, :volume_compensated => 23},
  #         { :value => '2', :count => 1, :volume => 22, :volume_compensated => 23},
  #       ]
  #     },
  #     { :value => '2009', :count => 2, :volume => 44, :volume_compensated => 46,
  #       :rows => [
  #         { :value => '1', :count => 1, :volume => 22, :volume_compensated => 23},
  #         { :value => '2', :count => 1, :volume => 22, :volume_compensated => 23},
  #       ]
  #     }
  #   ]
  # }
  def test_index_with_2_dimension
    get user_drilldown_index_path, params: { search: { dimensions: %w[year month],
                                                              filter: { calendar_date: %w[2009-01-01
                                                                                          2009-03-30] } } }
    assert_response :success
  end

  # { :value => 'All', :count => 8, :volume => 176, :volume_compensated => 184 [
  #   {
  #     :value => '2008', :count => 4, :volume => 88, :volume_compensated => 92,
  #     :rows => [
  #       {
  #         :value => '1', :count => 2, :volume => 44, :volume_compensated => 46,
  #         :rows => [
  #           {:value => '1', :count => 1, :volume => 22, :volume_compensated => 23},
  #           {:value => '2', :count => 1, :volume => 22, :volume_compensated => 23},
  #         ]
  #       },
  #       {
  #         :value => '2', :count => 2, :volume => 44, :volume_compensated => 46,
  #         :rows => [
  #           {:value => '1', :count => 1, :volume => 22, :volume_compensated => 23},
  #           {:value => '2', :count => 1, :volume => 22, :volume_compensated => 23},
  #         ]
  #       },
  #     ]
  #   },
  #   {
  #     :value => '2009', :count => 4, :volume => 88, :volume_compensated => 92,
  #     :rows => [
  #       {
  #         :value => '1', :count => 2, :volume => 44, :volume_compensated => 46,
  #         :rows => [
  #           {:value => '1', :count => 1, :volume => 22, :volume_compensated => 23},
  #           {:value => '2', :count => 1, :volume => 22, :volume_compensated => 23},
  #         ]
  #       },
  #       {
  #         :value => '2', :count => 2, :volume => 44, :volume_compensated => 46,
  #         :rows => [
  #           {:value => '1', :count => 1, :volume => 22, :volume_compensated => 23},
  #           {:value => '2', :count => 1, :volume => 22, :volume_compensated => 23},
  #         ]
  #       },
  #     ]
  #   },
  # ]
  def test_index_with_3_dimension
    get user_drilldown_index_path, params: { search: { dimensions: %w[year month day_of_month],
                                                              filter: { calendar_date: %w[2009-01-01
                                                                                          2009-03-30] } } }
    assert_response :success
  end

  def test_empty_result_with_0_dimension
    get user_drilldown_index_path, params: { search: { display_type: 'NONE',
                                                              filter: { calendar_date: '2009-06-04' } } }
    assert_response :success
  end

  def test_empty_result_with_1_dimension
    get user_drilldown_index_path, params: { search: {
      dimensions: ['month'], display_type: 'NONE', filter: { calendar_date: '2009-06-04' }
    } }
    assert_response :success
  end

  def test_empty_result_with_2_dimension
    get user_drilldown_index_path, params: { search: {
      dimensions: %w[year month], display_type: 'NONE',
      filter: { calendar_date: '2009-06-04' }
    } }
    assert_response :success
  end

  def test_empty_result_with_3_dimension
    get user_drilldown_index_path, params: { search: {
      dimensions: %w[year month day_of_month], display_type: 'NONE',
      filter: { calendar_date: '2009-06-04' }
    } }
    assert_response :success
  end

  def test_multiple_joins_to_contract_in_legal_values
    get user_drilldown_index_path, params: { search: {
      dimensions: ['year'],
      filter: {
        calendar_date: %w[2009-01-01 2009-03-30],
        month: ['10'],
        year: ['Person One'],
      },
    } }
    assert_response :success
  end

  def test_html_export
    get user_drilldown_html_export_path,
        params: { search: { filter: { calendar_date: '2010-03-30' } } }
    assert_response :success
  end

  def test_excel_export
    get user_drilldown_excel_export_path
    assert_response :success
  end

  def test_excel_export_with_filter
    get user_drilldown_excel_export_path,
        params: { search: { filter: { calendar_date: '2010-03-30' } } }
    assert_response :success
  end

  def test_excel_export_records
    get user_drilldown_excel_export_records_path
    assert_response :success
  end

  def test_excel_export_records_with_filter
    get user_drilldown_excel_export_records_path,
        params: { search: { filter: { calendar_date: '2010-03-30' } } }
    assert_response :success
  end

  def test_filter_with_single_value
    get user_drilldown_index_path, params: { search: { display_type: 'NONE',
                                                              filter: { month: '10' } } }
    assert_response :success
  end

end
