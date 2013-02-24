module ActiveAudit
  module ActiveRecord
    module ActMacro
      extend ActiveSupport::Concern

      module ClassMethods
        def audit_trail(options = {})
          return if audit?
          
          class_attribute :audit_class, instance_writer: false
          setup_audit_class

          extend ActiveAudit::ActiveRecord::ClassMethods
          include ActiveAudit::ActiveRecord::InstanceMethods
        end

        def audit?
          self.included_modules.include?(ActiveAudit::ActiveRecord::InstanceMethods)
        end
        
        private
        def setup_audit_class
          klass = self.const_get(:Audit) rescue nil
          if klass.nil? || klass.class_name != (self.class_name + "Audit")
            klass = self.const_set(:Audit, Class.new(ActiveAudit::Mongoid::Audit))
            klass.store_in collection: klass.name.gsub('::', '_').tableize
          end

          self.audit_class = klass
        end
      end
    end
  end
end