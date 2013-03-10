module ActiveAudit
  module ActiveRecord
    module ClassMethods
      def audit_class
        return @audit_class if @audit_class

        if audit_options[:class_name].present?
          klass = audit_options[:class_name].constantize
        elsif reflection = reflect_on_association(audit_options[:scope])
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

      def track_history?
        ActiveAudit.enabled? and track_history_per_model
      end

      def disable_tracking
        self.track_history_per_model = false
      end

      def enable_tracking
        self.track_history_per_model = true
      end

      def without_tracking
        tracking_was_enabled = self.track_history_per_model
        disable_tracking
        yield
      ensure
        enable_tracking if tracking_was_enabled
      end
    end
  end
end