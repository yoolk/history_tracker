module ActiveAudit
  module ActiveRecord
    module ActMacro
      extend ActiveSupport::Concern

      module ClassMethods
        def audit_trail(options = {})
          return if audit?

          options[:scope] ||= self.name.underscore
          class_attribute :audit_options, instance_writer: false
          self.audit_options = options

          delegate :track_history?, :to => 'self.class'
          class_attribute :track_history_per_model, instance_writer: false
          self.track_history_per_model = true

          setup_audit_trail!

          extend ActiveAudit::ActiveRecord::ClassMethods
          include ActiveAudit::ActiveRecord::InstanceMethods
        end

        def audit?
          self.included_modules.include?(ActiveAudit::ActiveRecord::InstanceMethods)
        end

        private
        def setup_audit_trail!
          audit_column!
          audit_callback!
        end

        def audit_column!
          class_attribute :audited_columns, instance_writer: false
          class_attribute :non_audited_columns, instance_writer: false

          if audit_options[:only]
            except = column_names - audit_options[:only].flatten.map(&:to_s)
          else
            except = ActiveAudit.ignored_attributes
            except |= Array(audit_options[:except]).collect(&:to_s) if audit_options[:except]
          end
          self.non_audited_columns = except
          self.audited_columns = column_names - except
        end

        def audit_callback!
          after_create   :audit_create   if !audit_options[:on] || (audit_options[:on] && audit_options[:on].include?(:create))
          before_update  :audit_update   if !audit_options[:on] || (audit_options[:on] && audit_options[:on].include?(:update))
          before_destroy :audit_destroy  if !audit_options[:on] || (audit_options[:on] && audit_options[:on].include?(:destroy))
        end
      end
    end
  end
end