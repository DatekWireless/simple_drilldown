# frozen_string_literal: true

xml.chart(xAxisName: 'Elections',
          showValues: '1', caption:, subcaption:,
          yAxisName: "Election #{t(@search.select_value.downcase)}", numberSuffix: '') do
  xml.set(
    name: @result[:value0],
    value: @result[:count]
  )
end
