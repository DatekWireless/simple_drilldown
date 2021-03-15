# frozen_string_literal: true

module SimpleDrilldown
  # Allow tracking changes for a field
  module Changes
    def self.included(clazz)
      clazz.extend ClassMethods
    end

    # Class methods for Changes
    module ClassMethods
      def changes_for(*fields)
        fields.each do |field|
          condition_proc = lambda do
            in_join = is_a?(ActiveRecord::Associations::JoinDependency::JoinAssociation)
            table_alias = in_join ? aliased_table_name : AuditLog.table_name
            "#{table_alias}.new_values LIKE '%#{field}%'"
          end
          has_many :"#{field}_changes", -> { where(condition_proc.call).order(:created_at) },
                   class_name: :AuditLog, foreign_key: :record_id
        end
      end
    end
  end
end
