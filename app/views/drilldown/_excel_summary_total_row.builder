# frozen_string_literal: true

xml.Row do
  1.upto(dimension) { |_n| xml.Cell('ss:StyleID' => 'Outer') }

  (@dimensions.size - dimension).times do |i|
    xml.Cell 'ss:Index' => (dimension + i + 1).to_s, 'ss:StyleID' => 'Sum' do
      xml.Data '', 'ss:Type' => 'String'
    end
  end
  xml.Cell 'ss:Index' => (@dimensions.size + 1).to_s, 'ss:StyleID' => 'Sum' do
    xml.Data result[:count], 'ss:Type' => 'Number'
  end
end
