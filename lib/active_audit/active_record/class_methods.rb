module ActiveAudit
  module ActiveRecord
    module ClassMethods
      def audit_class
        return @audit_class if @audit_class

        if audit_options[:class_name].present?
          klass = audit_options[:class_name].constantize
        elsif reflections[audit_options[:scope]].present?
          reflection = reflections.find { |name, reflection| name == audit_options[:scope] }[1]
          klass = reflection.klass.audit_class
        else
          klass = self.const_get(:Audit) rescue nil
          if klass.nil? || klass.class_name != (self.class_name + 'Audit')
            collection_name = "#{self.name}::Audit".gsub('::', '_').tableize
            klass = Class.new do
              include ActiveAudit::Mongoid::AuditTrail
              store_in collection: collection_name
            end
            klass = self.const_set(:Audit, klass)
          end
        end

        @audit_class = klass
      end
    end
  end
end