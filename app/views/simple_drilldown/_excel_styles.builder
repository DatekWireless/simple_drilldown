# frozen_string_literal: true

xml.Styles do
  xml.Style 'ss:ID' => 'Default', 'ss:Name' => 'Normal' do
    xml.Alignment 'ss:Vertical' => 'Center'
    xml.Borders
    xml.Font 'ss:FontName' => 'Calibri', 'x:Family' => 'Swiss', 'ss:Size' => '11', 'ss:Color' => '#000000'
    xml.Interior
    xml.NumberFormat
    xml.Protection
  end
  xml.Style 'ss:ID' => 'MainTitle' do
    xml.Alignment 'ss:Horizontal' => 'Center', 'ss:Vertical' => 'Bottom'
    xml.Font 'ss:Size' => '14', 'ss:Bold' => '1'
  end
  xml.Style 'ss:ID' => 'SubTitle' do
    xml.Alignment 'ss:Horizontal' => 'Center', 'ss:Vertical' => 'Bottom'
    xml.Font 'ss:Size' => '12', 'ss:Bold' => '1'
  end
  xml.Style 'ss:ID' => 'Heading' do
    xml.Font 'ss:Bold' => '1'
    xml.Alignment 'ss:Horizontal' => 'Center', 'ss:Vertical' => 'Bottom'
  end
  xml.Style 'ss:ID' => 'DimensionHeading' do
    xml.Font 'ss:Bold' => '1'
  end
  xml.Style 'ss:ID' => 'StandardNumberFormat' do
    xml.NumberFormat 'ss:Format' => 'Standard'
  end
  xml.Style 'ss:ID' => 'ThreeDecimalNumberFormat' do
    xml.NumberFormat 'ss:Format' => '0.000'
  end
  xml.Style 'ss:ID' => 'NoDecimalNumberFormat' do
    xml.NumberFormat 'ss:Format' => '#,##0'
  end
  xml.Style 'ss:ID' => 'Percent' do
    xml.NumberFormat 'ss:Format' => '0%'
  end
  xml.Style 'ss:ID' => 'Sum' do
    xml.Borders do
      %w[Top Left Right].each do |pos|
        xml.Border 'ss:Position' => pos
      end
      xml.Border 'ss:Position' => 'Bottom', 'ss:Weight' => '1'
    end
    xml.Interior 'ss:Color' => '#dedede', 'ss:Pattern' => 'Solid'
    xml.NumberFormat 'ss:Format' => '#,##0'
  end
  xml.Style 'ss:ID' => 'Outer'
  xml.Style 'ss:ID' => 'ShortDate' do
    xml.NumberFormat 'ss:Format' => 'Short Date'
  end
  xml.Style 'ss:ID' => 'NormalDate' do
    xml.NumberFormat 'ss:Format' => 'Long Date'
  end
  xml.Style 'ss:ID' => 'DateOnlyFormat' do
    xml.NumberFormat 'ss:Format' => 'd/m/yyyy;@'
  end
  xml.Style 'ss:ID' => 'TimeOnlyFormat' do
    xml.NumberFormat 'ss:Format' => 'hh:mm;@'
  end
  xml.Style 'ss:ID' => 'LongDate' do
    xml.NumberFormat 'ss:Format' => 'dd/mm/yyyy\\ hh:mm:ss'
  end
  xml.Style 'ss:ID' => 'VerticalCenter' do
    xml.Alignment 'ss:Vertical' => 'Center'
  end
end
