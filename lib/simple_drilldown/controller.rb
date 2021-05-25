# frozen_string_literal: true

require 'simple_drilldown/helper'
require 'simple_drilldown/search'

module SimpleDrilldown
  class Controller < ::ApplicationController
    helper Helper

    LIST_LIMIT = 10_000

    class_attribute :c_base_condition, default: '1=1'
    class_attribute :c_base_group, default: []
    class_attribute :c_base_includes, default: []
    class_attribute :c_default_fields, default: []
    class_attribute :c_default_select_value, default: SimpleDrilldown::Search::SelectValue::COUNT
    class_attribute :c_dimension_defs
    class_attribute :c_fields, default: []
    class_attribute :c_list_includes, default: []
    class_attribute :c_list_order
    class_attribute :c_select, default: 'count(*) as count'
    class_attribute :c_summary_fields, default: []
    class_attribute :c_target_class

    class << self
      def inherited(base)
        super
        base.c_dimension_defs = Concurrent::Hash.new
        base.c_fields = {}
        begin
          base.c_target_class = base.name.chomp('DrilldownController').constantize
        rescue NameError
          begin
            base.c_target_class = base.name.chomp('Controller').constantize
          rescue NameError
            # No default target class found
          end
        end
        return unless base.c_target_class.try :paranoid?

        base.c_base_condition = "#{base.c_target_class.table_name}.deleted_at IS NULL"
      end

      def base_condition(base_condition)
        self.c_base_condition = base_condition
      end

      def base_includes(*base_includes)
        self.c_base_includes = base_includes.flatten
      end

      def base_group(base_group)
        self.c_base_group = base_group
      end

      def default_fields(default_fields)
        self.c_default_fields = default_fields.flatten
      end

      def default_select_value(default_select_value)
        self.c_default_select_value = default_select_value.to_sym
      end

      def target_class(target_class)
        self.c_target_class = target_class
      end

      def select(select)
        self.c_select = select
      end

      def list_includes(*list_includes)
        self.c_list_includes = list_includes.flatten
      end

      def list_order(list_order)
        self.c_list_order = list_order
      end

      def field(name, **options)
        c_fields[name] = options
      end

      def summary_fields(*summary_fields)
        self.c_summary_fields = summary_fields.flatten
      end

      def dimension(name, select_expression = name, options = {})
        interval = options.delete(:interval)
        label_method = options.delete(:label_method)
        legal_values = options.delete(:legal_values) || legal_values_for(name)
        reverse = options.delete(:reverse)
        row_class = options.delete(:row_class)
        if select_expression.is_a?(Array)
          queries = select_expression
        else
          includes = options.delete(:includes)
          conditions = options.delete(:where)
          queries = [{
            select: select_expression,
            includes: includes,
            where: conditions
          }]
        end
        raise "Unexpected options: #{options.inspect}" if options.present?

        queries.each do |query_opts|
          unless (query_opts.keys - %i[select includes where]).empty?
            raise "Unknown options: #{query_opts.keys.inspect}"
          end
        end

        c_dimension_defs[name.to_s] = {
          includes: queries.inject(nil) do |a, e|
            i = e[:includes]
            next a unless i
            next a if a&.include?(i)

            case a
            when nil
              i
            when Symbol
              [a, *i]
            else
              a.concat(*i)
            end
          end,
          interval: interval,
          label_method: label_method,
          legal_values: legal_values,
          pretty_name: I18n.t(name, default: [:"activerecord.models.#{name}", name.to_s.titleize]),
          queries: queries,
          reverse: reverse,
          select_expression:
            queries.size == 1 ? queries[0][:select] : "COALESCE(#{queries.map { |q| q[:select] }.join(',')})",
          row_class: row_class,
          url_param_name: name.to_s
        }
      end

      def legal_values_for(field, preserve_filter = false)
        lambda do |search|
          my_filter = search.filter.dup
          my_filter.delete(field.to_s) unless preserve_filter
          filter_conditions, _t, includes = make_conditions(my_filter)
          dimension_def = c_dimension_defs[field.to_s]
          result_sets = dimension_def[:queries].map do |query|
            if query[:includes]
              if query[:includes].is_a?(Array)
                includes += query[:includes]
              else
                includes << query[:includes]
              end
              includes.uniq!
            end
            rows_query = c_target_class.unscoped.where(c_base_condition)
                                       .select("#{query[:select]} AS value")
                                       .joins(make_join([], c_target_class.name.underscore.to_sym, includes))
                                       .order('value')
                                       .group(:value)
            # rows_query = rows_query.without_deleted if c_target_class.try :paranoid?
            rows_query = rows_query.where(filter_conditions) if filter_conditions
            rows_query = rows_query.where(query[:where]) if query[:where]
            rows = rows_query.to_a
            filter_fields = search.filter[field.to_s]
            filter_fields&.each do |selected_value|
              next if rows.find { |r| r[:value].to_s == selected_value }

              # FIXME(uwe):  Convert the selected value to same data type as legal values
              rows << { value: selected_value }
              # EMXIF
            end
            rows.map { |r| [dimension_def[:label_method]&.call(r[:value]) || r[:value], r[:value]] }
          end
          values = result_sets.inject(&:+).uniq
          values.sort! if dimension_def[:queries].size > 1
          values.reverse! if dimension_def[:reverse]
          values
        end
      end

      def make_conditions(search_filter)
        includes = c_base_includes.dup
        if search_filter
          condition_strings = []
          condition_values = []

          filter_texts = []
          search_filter.each do |field, values|
            dimension_def = c_dimension_defs[field]
            raise "Unknown filter field: #{field.inspect}" if dimension_def.nil?

            values = Array(values)
            if dimension_def[:interval]
              if values[0].present? && values[1].present?
                condition_strings << "#{dimension_def[:select_expression]} BETWEEN ? AND ?"
                condition_values += values
                filter_texts << <<~TEXT
                  #{dimension_def[:pretty_name]} #{dimension_def[:label_method]&.call(values) || "from #{values[0]} to #{values[1]}"}
                TEXT
              elsif values[0].present?
                condition_strings << "#{dimension_def[:select_expression]} >= ?"
                condition_values << values[0]
                filter_texts <<
                  "#{dimension_def[:pretty_name]} #{dimension_def[:label_method]&.call(values) || "from #{values[0]}"}"
              elsif values[1].present?
                condition_strings << "#{dimension_def[:select_expression]} <= ?"
                condition_values << values[1]
                filter_texts <<
                  "#{dimension_def[:pretty_name]} #{dimension_def[:label_method]&.call(values) || "to #{values[1]}"}"
              end
              includes << dimension_def[:includes] if dimension_def[:includes]
            else
              condition_strings << values.map do |value|
                if dimension_def[:condition_values_method]
                  condition_values += dimension_def[:condition_values_method].call(value)
                else
                  condition_values << value
                end
                filter_texts <<
                  "#{dimension_def[:pretty_name]} #{dimension_def[:label_method]&.call(value) || value}"
                includes << dimension_def[:includes] if dimension_def[:includes]
                "(#{dimension_def[:select_expression]}) = ?"
              end.join(' OR ')
            end
          end
          filter_text = filter_texts.join(' and ')
          conditions = [condition_strings.map { |c| "(#{c})" }.join(' AND '), *condition_values]
          includes.keep_if(&:present?).uniq!
        else
          filter_text = nil
          conditions = nil
        end
        conditions = nil if conditions == ['']
        [conditions, filter_text, includes]
      end

      def make_join(joins, model, include, model_class = model.to_s.camelize.constantize)
        case include
        when Array
          include.map { |i| make_join(joins, model, i) }.join(' ')
        when Hash
          sql = +''
          include.each do |parent, child|
            sql << " #{make_join(joins, model, parent)}"
            ass = model.to_s.camelize.constantize.reflect_on_association parent
            sql << " #{make_join(joins, parent, child, ass.class_name.constantize)}"
          end
          sql
        when Symbol
          return '' if joins.include?(include)

          joins = joins.dup
          joins << include
          ass = model_class.reflect_on_association include
          raise "Unknown association: #{model} => #{include}" unless ass

          model_table = model.to_s.pluralize
          include_table = ass.table_name
          include_alias = include.to_s.pluralize
          case ass.macro
          when :belongs_to
            pk_col = ass.association_primary_key
            fk_col = ass.options[:foreign_key] || "#{include}_id"
            "LEFT JOIN #{include_table} #{include_alias} ON #{include_alias}.#{pk_col} = #{model_table}.#{fk_col}"
          when :has_one, :has_many
            fk_col = ass.options[:foreign_key] || "#{model}_id"
            sql = +"LEFT JOIN #{include_table} #{include_alias} ON #{include_alias}.#{fk_col} = #{model_table}.id"
            sql << " AND #{include_alias}.deleted_at IS NULL" if ass.klass.paranoid?
            if ass.scope && (ass_order = ScopeHolder.new(ass.scope).to_s)
              ass_order = ass_order.sub(/ DESC\s*$/i, '')
              ass_order_prefixed = ass_order.dup
              ActiveRecord::Base.connection.columns(include_table).map(&:name).each do |cname|
                ass_order_prefixed.gsub!(/\b#{cname}\b/, "#{include_alias}.#{cname}")
              end
              paranoid_clause = 'AND t2.deleted_at IS NULL' if ass.klass.paranoid?
              # FIXME(uwe):  Should we add "where" from the ScopeHolder here as well?
              #              Ref: SimpleDrilldown::Changes#changes_for
              min_query = <<~SQL
                SELECT MIN(#{ass_order}) FROM #{include_table} t2 WHERE t2.#{fk_col} = #{model_table}.id #{paranoid_clause}
              SQL
              sql << " AND  #{ass_order_prefixed} = (#{min_query})"
            end
            sql
          else
            raise "Unknown association type: #{ass.macro}"
          end
        when String
          include
        when nil
          ''
        else
          raise "Unknown join class: #{include.inspect}"
        end
      end
    end

    def initialize
      super()
      @history_fields = c_fields.select { |_k, v| v[:list_change_times] }.map { |k, _v| k.to_s }
    end

    # ?dimension[0]=supplier&dimension[1]=transaction_type&
    # filter[year]=2009&filter[supplier][0]=Shell&filter[supplier][1]=Statoil
    def index(do_render = true)
      @search = new_search_object

      @transaction_fields = (@search.fields + (c_fields.keys.map(&:to_s) - @search.fields))

      select = c_select.dup
      includes = c_base_includes.dup

      @dimensions = []
      select << ", 'All'#{'::text' if c_target_class.connection.adapter_name == 'PostgreSQL'} as value0"
      @dimensions += @search.dimensions.map do |dn|
        raise "Unknown distribution field: #{dn.inspect}" if c_dimension_defs[dn].nil?

        c_dimension_defs[dn]
      end
      @dimensions.each_with_index do |d, i|
        select << ", #{d[:select_expression]} as value#{i + 1}"
        includes << d[:includes] if d[:includes]
      end

      conditions, @filter_text, filter_includes = self.class.make_conditions(@search.filter)
      includes += filter_includes
      includes.flatten!
      includes.keep_if(&:present?).uniq!
      if @search.order_by_value && @dimensions.size <= 1
        order = "#{c_summary_fields.find { |f| f == @search.select_value } || 'count'} DESC"
      else
        order = (1..@dimensions.size).map { |i| "value#{i}" }.join(',')
        order = nil if order.empty?
      end
      group = (c_base_group + (1..@dimensions.size).map { |i| "value#{i}" }).join(',')
      group = nil if group.empty?

      joins = self.class.make_join([], c_target_class.name.underscore.to_sym, includes)
      rows = c_target_class.unscoped.where(c_base_condition).select(select).where(conditions)
                           .joins(joins)
                           .group(group)
                           .order(order)
                           .to_a
      if rows.empty?
        @result = { value: 'All', count: 0, row_count: 0, nodes: 0, rows: [] }
        c_summary_fields.each { |f| @result[f] = 0 }
      else
        if do_render && @search.list && rows.inject(0) { |sum, r| sum + r[:count].to_i } > LIST_LIMIT
          @search.list = false
          flash.now[:notice] = "More than #{LIST_LIMIT} records.  List disabled."
        end
        @result = result_from_rows(rows, 0, 0, ['All'])
      end

      remove_duplicates(@result) unless c_base_group.empty?

      @remaining_dimensions = c_dimension_defs.dup
      @remaining_dimensions.each_key do |dim_name|
        if (@search.filter[dim_name] && @search.filter[dim_name].size == 1) ||
           (@dimensions.any? { |d| d[:url_param_name] == dim_name })
          @remaining_dimensions.delete(dim_name)
        end
      end

      populate_list(conditions, includes, @result, []) if @search.list
      render template: '/drilldown/index' if do_render
    end

    def choices
      @search = new_search_object
      dimension_name = params[:dimension_name]
      dimension = c_dimension_defs[dimension_name]
      selected = @search.filter[dimension_name] || []
      raise "Unknown dimension #{dimension_name.inspect}: #{c_dimension_defs.keys.inspect}" unless dimension

      choices = [[t(:all), nil]] + (legal_values_for_dimension(dimension) || [])
      choices_html = choices.map do |c|
        %(<option value="#{c[1]}"#{' SELECTED' if selected.include?(c[1])}>#{c[0]}</option>)
      end.join("\n")
      render html: choices_html.html_safe
    end

    def html_export
      index(false)
      render template: '/drilldown/html_export', layout: '../drilldown/print'
    end

    def excel_export
      index(false)
      respond_to do |format|
        format.xlsx do
          render xlsx: c_target_class.table_name, template: 'drilldown/excel_export_xlsx'
        end
        format.xml do
          set_excel_headers
          if params.dig(:search, :list) == '1'
            @records = get_records(@result)
            render template: 'drilldown/excel_export_records', layout: false
          else
            render template: 'drilldown/excel_export', layout: false
          end
        end
      end
    end

    def excel_export_records
      params[:search] ||= {}
      params[:search][:list] = '1'
      excel_export
    end

    private

    def set_excel_headers
      headers['Content-Type'] = 'application/vnd.ms-excel'
      headers['Content-Disposition'] = %{attachment; filename="#{c_target_class.table_name}.xml"}
      headers['Cache-Control'] = ''
    end

    def legal_values_for_dimension(dimension)
      dimension[:legal_values]&.call(@search)&.map { |o| o.is_a?(Array) ? o[0..1].map(&:to_s) : o.to_s }
    end

    def new_search_object
      SimpleDrilldown::Search.new(params[:search]&.to_unsafe_h, c_default_fields, c_default_select_value)
    end

    def remove_duplicates(result)
      rows = result[:rows]
      return 0 unless rows

      removed_rows = 0
      prev_row = nil
      rows.each do |r|
        if prev_row
          if prev_row[:value] == r[:value]
            prev_row[:count] += r[:count]
            c_summary_fields.each do |f|
              prev_row[f] += r[f]
            end
            prev_row[:row_count] = [prev_row[:row_count], r[:row_count]].max
            prev_row[:nodes] = [prev_row[:nodes], r[:nodes]].max
            prev_row[:rows] += r[:rows] if prev_row[:rows] || r[:rows]
            r[:value] = nil
            removed_rows += r[:nodes]
          end
        end
        prev_row = r unless r[:value].nil?
      end
      rows.delete_if { |r| r[:value].nil? }
      rows.each do |r|
        removed_child_rows = remove_duplicates(r)
        removed_rows += removed_child_rows
      end
      result[:row_count] -= removed_rows
      result[:nodes] -= removed_rows
      removed_rows
    end

    # Empty summary rows are needed to plot zero points in the charts
    def add_zero_results(result_rows, dimension)
      legal_values =
        self.class.legal_values_for(@dimensions[dimension][:url_param_name], true).call(@search).map { |lv| lv[1] }
      legal_values.reverse! if @dimensions[dimension][:reverse]
      current_values = result_rows.map { |r| r[:value] }.compact
      empty_values = legal_values - current_values

      unless empty_values.empty?
        empty_values.each do |v|
          sub_result = {
            value: v,
            count: 0,
            row_count: 0,
            nodes: 0
          }
          c_summary_fields.each { |f| sub_result[f] = 0 }
          sub_result[:rows] = add_zero_results([], dimension + 1) if dimension < @dimensions.size - 1
          result_rows << sub_result
        end
        result_rows = result_rows.sort_by { |r| legal_values.index(r[:value]) }
      end
      result_rows
    end

    def result_from_rows(rows, row_index, dimension, previous_values)
      row = rows[row_index]
      return nil if row.nil?

      values = (0..dimension).to_a.map { |i| row["value#{i}"] }
      return nil if values != previous_values

      if dimension == @dimensions.size
        result = {
          value: values[-1],
          count: row[:count].to_i,
          row_count: 1,
          nodes: @search.list ? 2 : 1
        }
        c_summary_fields.each { |f| result[f] = row[f].to_i }
        return result
      end

      result_rows = []
      loop do
        sub_result = result_from_rows(rows, row_index, dimension + 1,
                                      values + [rows[row_index]["value#{dimension + 1}"]])
        break if sub_result.nil?

        result_rows << sub_result
        row_index += sub_result[:row_count]
        break if rows[row_index].nil?
      end

      result_rows = add_zero_results(result_rows, dimension)

      result = {
        value: values[-1],
        count: result_rows.inject(0) { |t, r| t + r[:count].to_i },
        row_count: result_rows.inject(0) { |t, r| t + r[:row_count] },
        nodes: result_rows.inject(0) { |t, r| t + r[:nodes] } + 1,
        rows: result_rows
      }
      c_summary_fields.each { |f| result[f] = result_rows.inject(0) { |t, r| t + r[f] } }
      result
    end

    def populate_list(conditions, includes, result, values)
      return result[:rows].each { |r| populate_list(conditions, includes, r, values + [r[:value]]) } if result[:rows]

      list_includes = merge_includes(includes, c_list_includes)
      @search.fields.each do |field|
        field_def = c_fields[field.to_sym]
        raise "Field definition missing for: #{field.inspect}" unless field_def

        field_includes = field_def[:include]
        list_includes = merge_includes(list_includes, field_includes) if field_includes
      end
      if @search.list_change_times
        @history_fields.each do |f|
          if @search.fields.include? f
            list_includes = merge_includes(list_includes, assignment: { order: :"#{f}_changes" })
          end
        end
      end
      joins = self.class.make_join([], c_target_class.name.underscore.to_sym, list_includes)
      list_conditions = list_conditions(conditions, values)
      base_query = c_target_class.unscoped.where(c_base_condition).joins(joins).order(c_list_order)
      base_query = base_query.where(list_conditions) if list_conditions
      result[:records] = base_query.to_a
    end

    def merge_includes(*args)
      hash = hash_includes(*args)
      result = hash.dup.map do |k, v|
        if v.blank?
          hash.delete(k)
          k
        end
      end.compact
      result << hash unless hash.blank?
      case result.size
      when 0
        nil
      when 1
        result[0]
      else
        result
      end
    end

    def hash_includes(*args)
      args.inject({}) do |h, inc|
        case inc
        when Array
          inc.each do |v|
            h = hash_includes(h, v)
          end
        when Hash
          inc.each do |k, v|
            h[k] = merge_includes(h[k], v)
          end
        when NilClass, FalseClass
          # Leave as it is
        when String, Symbol
          h[inc] ||= []
        else
          raise "Unknown include type: #{inc.inspect}"
        end
        h
      end
    end

    def list_conditions(conditions, values)
      conditions ||= ['']

      list_conditions_string = conditions[0].dup
      @dimensions.each do |d|
        list_conditions_string << "#{' AND ' unless list_conditions_string.empty?}#{d[:select_expression]} = ?"
      end
      [list_conditions_string, *(conditions[1..-1] + values)]
    end

    def get_records(tree)
      return tree[:records] if tree[:records]

      tree[:rows].map { |r| get_records(r) }.flatten
    end

    class ScopeHolder
      def initialize(scope)
        instance_eval(&scope)
      end

      def order(order)
        @order = order
        self
      end

      def where(*_conditions)
        self
      end

      def to_s
        if @order.is_a?(Hash)
          @order.map { |field, direction| "#{field} #{direction}" }.join(', ')
        else
          @order.to_s
        end
      end
    end
  end
end
