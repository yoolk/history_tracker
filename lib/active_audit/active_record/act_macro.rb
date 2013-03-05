module ActiveAudit
  module ActiveRecord
    module ActMacro
      extend ActiveSupport::Concern

      module ClassMethods
        def audit_trail(options = {})
          return if audit?
          
          options[:scope] ||= self.name.underscore.to_sym
          setup_audit_trail!(options)

          extend ActiveAudit::ActiveRecord::ClassMethods
          include ActiveAudit::ActiveRecord::InstanceMethods
        end

        def audit?
          self.included_modules.include?(ActiveAudit::ActiveRecord::InstanceMethods)
        end

        private
        def setup_audit_trail!(options)
          audit_options!(options)
          audit_class!(options)
          audit_column!(options)
          audit_callback!(options)
        end

        def audit_options!(options)
          class_attribute :audit_options, instance_writer: false
          self.audit_options = options
        end

        def audit_class!(options)
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

        def audit_column!(options)
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

        def audit_callback!(options)
          after_create   :audit_create   if !options[:on] || (options[:on] && options[:on].include?(:create))
          before_update  :audit_update   if !options[:on] || (options[:on] && options[:on].include?(:update))
          before_destroy :audit_destroy  if !options[:on] || (options[:on] && options[:on].include?(:destroy))
        end
      end
    end
  end
end