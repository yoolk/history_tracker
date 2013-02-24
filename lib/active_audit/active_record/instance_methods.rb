module ActiveAudit
  module ActiveRecord
    module InstanceMethods
      def audit
        @audit ||= audit_class.find_or_initialize_by(resource_id: id)
      end

      private
      def audited_attributes
        attributes.except(*non_audited_columns)
      end
    end
  end
end