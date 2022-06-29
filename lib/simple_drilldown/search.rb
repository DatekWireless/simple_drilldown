# frozen_string_literal: true

require 'active_model/naming'

module SimpleDrilldown
  class Search
    extend ActiveModel::Naming

    module DisplayType
      BAR = 'BAR'
      LINE = 'LINE'
      NONE = 'NONE'
      PIE = 'PIE'
    end

    module SelectValue
      COUNT = :count
    end

    attr_reader :dimensions, :display_type, :fields, :filter, :list_change_times, :order_by_value,
                :select_value, :title, :default_fields
    attr_accessor :list, :percent

    def self.validators_on(_attribute)
      []
    end

    def self.human_attribute_name(attribute)
      attribute
    end

    def initialize(attributes_or_search, default_fields = nil, default_select_value = SelectValue::COUNT)
      if attributes_or_search.is_a? self.class
        s = attributes_or_search
        @dimensions = s.dimensions.dup
        @display_type = s.display_type.dup
        @fields = s.fields.dup
        @filter = s.filter.dup
        @list = s.list
        @percent = s.percent
        @list_change_times = s.list_change_times
        @order_by_value = s.order_by_value
        @select_value = s.select_value.dup
        @title = s.title
        @default_fields = s.default_fields
      else
        attributes = attributes_or_search
        @default_fields = default_fields
        @default_select_value = default_select_value
        @dimensions = (attributes && attributes[:dimensions]) || []
        @dimensions.delete_if(&:empty?)
        @filter = attributes && attributes[:filter] ? attributes[:filter] : {}
        @filter.keys.dup.each { |k| @filter[k] = Array(@filter[k]) }
        @filter.each do |_k, v|
          v.delete('')
          v.delete('Select Some Options')
        end
        @filter.delete_if { |_k, v| v.empty? }
        @display_type = attributes && attributes[:display_type] ? attributes[:display_type] : DisplayType::NONE
        @display_type = DisplayType::BAR if @dimensions.size >= 2 && @display_type == DisplayType::PIE

        @order_by_value = attributes && (attributes[:order_by_value] == '1')
        @select_value = attributes&.dig(:select_value).presence&.to_sym || @default_select_value
        @list = attributes&.[](:list) == '1'
        @percent = attributes&.[](:percent) == '1'
        @list_change_times = attributes&.[](:list_change_times) == '1'
        @fields = if attributes && attributes[:fields]
                    if attributes[:fields].is_a?(Array)
                      attributes[:fields]
                    else
                      attributes[:fields].to_h.select { |_k, v| v == '1' }.map { |k, _v| k }
                    end
                  else
                    @default_fields
                  end
        @title = attributes[:title] if attributes&.dig(:title).present?
      end
    end

    def url_options
      o = {
        search: {
          title: title,
          list: list ? '1' : '0',
          percent: percent ? '1' : '0',
          list_change_times: list_change_times ? '1' : '0',
          filter: filter,
          dimensions: dimensions,
          display_type: display_type
        }
      }
      o[:search][:fields] = fields unless fields == @default_fields
      o
    end

    # Used for DOM id
    def id
      'SEARCH'
    end

    def list?
      list
    end

    def drill_down(dimensions, *values)
      raise 'Too many values' if values.size > self.dimensions.size

      s = self.class.new(self)
      values.each_with_index { |v, i| s.filter[dimensions[i][:url_param_name]] = [v] }
      values.size.times { s.dimensions.shift }
      s
    end

    def to_key
      url_options.to_a
    end
  end
end
