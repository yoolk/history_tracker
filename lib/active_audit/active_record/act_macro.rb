module ActiveAudit
  module ActiveRecord
    module ActMacro
      extend ActiveSupport::Concern

      module ClassMethods
        def audit_trail(options = {})
          return if audit?
          
          setup_audit_trail!(options)

          extend ActiveAudit::ActiveRecord::ClassMethods
          include ActiveAudit::ActiveRecord::InstanceMethods
        end

        def audit?
          self.included_modules.include?(ActiveAudit::ActiveRecord::InstanceMethods)
        end
        
        private
        def setup_audit_trail!(options)
          setup_audit_class!(options)
          setup_audit_column!(options)
        end

        def setup_audit_class!(options)
          class_attribute :audit_class, instance_writer: false

          klass = self.const_get(:Audit) rescue nil
          if klass.nil? || klass.class_name != (self.class_name + 'Audit')
            collection_name = "#{self.name}::Audit".gsub('::', '_').tableize
            klass = Class.new do
              include ActiveAudit::Mongoid::AuditTrail
              store_in collection: collection_name
            end
            klass = self.const_set(:Audit, klass)
          end

          self.audit_class = klass
        end

        def setup_audit_column!(options)
          class_attribute :audited_columns, instance_writer: false
          class_attribute :non_audited_columns, instance_writer: false

          if options[:only]
            except = column_names - options[:only].flatten.map(&:to_s)
          else
            except = ActiveAudit.ignored_attributes
            except |= Array(options[:except]).collect(&:to_s) if options[:except]
          end
          self.non_audited_columns = except
          self.audited_columns = column_names - except
        end
      end
    end
  end
end