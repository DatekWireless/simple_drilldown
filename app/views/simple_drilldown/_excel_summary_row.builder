# frozen_string_literal: true

xml.Row do
  1.upto(dimension - headers.size - 1) { |_n| xml.Cell('ss:StyleID' => 'Outer') }

  headers.each_with_index do |h, i|
    xml.Cell('ss:StyleID' => 'Outer', 'ss:Index' => (dimension - headers.size + i).to_s) do
      xml.Data value_label(@dimensions.size - headers.size + i - 1, h[:value]), 'ss:Type' => 'String'
    end
  end
  if dimension.positive?
    xml.Cell('ss:StyleID' => 'Outer',
             'ss:Index' => dimension.to_s) do
      xml.Data value_label(dimension - 1, result[:value]),
               'ss:Type' => 'String'
    end
  end

  xml.Cell('ss:StyleID' => 'Outer') { xml.Data result[:count].inspect, 'ss:Type' => 'Number' }
end
