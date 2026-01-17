# frozen_string_literal: true

module SimpleDrilldown
  # View helper for SimpleDrilldown
  module Helper
    # FIXME(uwe): Should not be necessary: https://github.com/rails/rails/issues/41038
    include Rails.application.routes.url_helpers

    # EMXIF

    def value_label(dimension_index, value)
      dimension = @dimensions[dimension_index]
      return nil if dimension.nil?

      h(dimension[:label_method] ? dimension[:label_method].call(value) : value)
    end

    def caption
      result = @search.title || caption_txt
      result.gsub('$date', Array(@search.filter[:calendar_date]).uniq.join(' - '))
    end

    def subcaption
      @search.title || @filter_text.blank? ? '' : "for #{@filter_text}"
    end

    def summary_row(result, parent_result = nil, dimension = 0, headers = [], new_row: true)
      html = render(partial: '/simple_drilldown/summary_row', locals: {
                      result:, parent_result:, new_row:, dimension:,
                      headers:, with_results: !result[:rows]
                    })
      if result[:rows]
        sub_headers = headers + [{
          value: result[:value],
          display_row_count: result[:nodes] + (result[:row_count] * (@search.list ? 1 : 0))
        }]
        significant_rows = result[:rows].reject { |r| r[:row_count].zero? }
        significant_rows.each_with_index do |r, i|
          html << summary_row(r, result, dimension + 1, sub_headers, new_row: i.positive?)
        end
      elsif @search.list
        html << render(partial: '/simple_drilldown/record_list', locals: { result:, dimension: })
      end
      if dimension < @dimensions.size
        html << render(partial: '/simple_drilldown/summary_total_row',
                       locals: {
                         result:, parent_result:, headers: headers.dup, dimension:
                       })
      end

      html
    end

    def excel_summary_row(result, parent_result = nil, dimension = 0, headers = [])
      xml = +''
      if result[:rows]
        significant_rows = result[:rows].reject { |r| r[:row_count].zero? }
        significant_rows.each_with_index do |r, i|
          sub_headers =
            if i.zero?
              if dimension.zero?
                headers
              else
                headers + [{
                  value: result[:value],
                  display_row_count: result[:nodes] + (result[:row_count] * (@search.list ? 1 : 0))
                }]
              end
            else
              [] # [{:value => result[:value], :row_count => result[:row_count]}]
            end
          xml << excel_summary_row(r, result, dimension + 1, sub_headers)
        end
      else
        xml << render(partial: '/simple_drilldown/excel_summary_row',
                      locals: { result:, parent_result:, headers: headers.dup,
                                dimension: })

        xml << render(partial: '/simple_drilldown/excel_record_list', locals: { result: }) if @search.list
      end

      if dimension < @dimensions.size
        xml << render(partial: '/simple_drilldown/excel_summary_total_row', locals: {
                        result:, headers: headers.dup, dimension:
                      })
      end
      xml
    end

    private

    def caption_txt
      class_txt = controller.c_target_class &&
                  I18n.t(controller.c_target_class.name.underscore.to_sym,
                         default: [controller.c_target_class.name.underscore.to_sym,
                                   controller.c_target_class.name.titleize])
      value_txt = I18n.t(@search.select_value.downcase, default: @search.select_value.to_s.titleize)
      dimensions_txt = " by #{@dimensions.map { |d| d[:pretty_name] }.join(' and ')}" if @dimensions&.any?
      "#{class_txt} #{value_txt}#{dimensions_txt}"
    end
  end
end
