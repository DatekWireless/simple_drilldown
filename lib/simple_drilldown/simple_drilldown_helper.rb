module TransactionDrillownHelper
  def value_label(dimension_index, value)
    return nil if @dimensions[dimension_index].nil?
    h(@dimensions[dimension_index][:label_method] ?
    @dimensions[dimension_index][:label_method].call(value) :
    value)
  end

  def caption
    result = @search.title ? @search.title : "Transaction #{l(@search.select_value.downcase)}" + (@dimensions && @dimensions[0] && @dimensions[0][:pretty_name] ? " by #{@dimensions[0][:pretty_name]}" : "")
    result.gsub('$date', [*@search.filter[:calendar_date]].uniq.join(' - '))
  end

  def subcaption
    @search.title ? '' : @filter_text && @filter_text.size > 0 ? "for #{@filter_text}" : ""
  end

  def summary_row(result, dimension = 0, headers = [], new_row = true)
    html = render(:partial => '/transaction_drilldown/summary_row', :locals => {:result => result, :new_row => new_row, :dimension => dimension, :headers => headers, :with_results => !result[:rows]})
    if result[:rows]
      sub_headers = headers + [{:value => result[:value], :display_row_count => result[:nodes] + result[:row_count] * (@search.list ? 1 : 0)}]
      significant_rows = result[:rows].select{|r| r[:row_count] != 0}
      significant_rows.each_with_index do |r, i|
        html << summary_row(r, dimension + 1, sub_headers, i > 0)
      end
    elsif @search.list
      html << render(:partial => '/transaction_drilldown/transaction_list', :locals => {:result => result})
    end
    if dimension < @dimensions.size
      html << render(:partial => '/transaction_drilldown/summary_total_row', :locals => {:result => result, :headers => headers.dup, :dimension => dimension})
    end

    return html
  end

  def excel_summary_row(result, dimension, headers)
    xml = ''
    if result[:rows]
      significant_rows = result[:rows].select{|r| r[:row_count] != 0}
      significant_rows.each_with_index do |r, i|
        if i == 0
          if dimension == 0
            sub_headers = headers
          else
            sub_headers = headers + [{:value => result[:value], :display_row_count => result[:nodes] + result[:row_count] * (@search.list ? 1 : 0)}]
          end
        else
          sub_headers = [] # [{:value => result[:value], :row_count => result[:row_count]}]
        end
        xml << excel_summary_row(r, dimension + 1, sub_headers)
      end
    else
      xml << render(:partial => '/transaction_drilldown/excel_summary_row', :locals => {:result => result, :headers => headers.dup, :dimension => dimension})

      if @search.list
        xml << render(:partial => '/transaction_drilldown/excel_transaction_list', :locals => {:result => result})
      end
    end

    if dimension < @dimensions.size
      xml << render(:partial => '/transaction_drilldown/excel_summary_total_row', :locals => {:result => result, :headers => headers.dup, :dimension => dimension})
    end
    xml
  end

end
