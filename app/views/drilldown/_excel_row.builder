# frozen_string_literal: true

xml.Row do
  padding_cells = @dimensions.empty? ? 1 : @dimensions.size
  1.upto(padding_cells - 1) { |_n| xml.Cell('ss:StyleID' => 'Outer') }

  @search.fields.each_with_index do |field, i|
    if field == 'time'
      value = (transaction.respond_to?(:completed_at) ? transaction.completed_at : transaction.created_at).localtime.strftime('%Y-%m-%d %H:%M')
    else
      value = if @transaction_fields_map[field.to_sym][:attr_method]
                @transaction_fields_map[field.to_sym][:attr_method].call(transaction)
              else
                transaction.send(field)
              end
    end

    field_def = @transaction_fields_map[field.to_sym]

    xml.Cell('ss:Index' => (padding_cells + i).to_s) do
      xml.Data value, 'ss:Type' => 'String'
    end
  end
end
