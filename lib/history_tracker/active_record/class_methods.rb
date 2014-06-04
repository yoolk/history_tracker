module HistoryTracker
  module ActiveRecord
    module ClassMethods
      def history_class
        return @history_class if @history_class

        if history_options[:class_name].present?
          klass = history_options[:class_name].constantize
        elsif reflection = reflect_on_association(history_options[:scope])
          klass = reflection.klass.history_class
        else
          klass = self.const_get(:History) rescue nil
          if klass.nil? || klass.class_name != (self.class_name + 'History')
            collection_name = "#{self.name}::History".gsub('::', '_').tableize
            klass = Class.new do
              include HistoryTracker::Mongoid::Tracker
              store_in collection: collection_name
            end
            klass = self.const_set(:History, klass)
          end
        end

        @history_class = klass
      end

      def history_tracks
        if defined? scoped.proxy_association
          if scoped.proxy_association.owner.class.name.downcase.to_sym == history_options[:scope]
            association_chain_name = scoped.proxy_association.owner.class.name
          else
            association_chain_name = scoped.proxy_association.owner.class.name.underscore.pluralize
          end

          history_class.where(
            { 'association_chain.id'   => scoped.proxy_association.owner.id, 
              'association_chain.name' => association_chain_name,
              'type'                   => scoped.proxy_association.reflection.name.to_s
            }
          )
        end
      end

      def track_history?
        HistoryTracker.enabled? and HistoryTracker.enabled_for_controller? and track_history_per_model
      end

      def disable_tracking
        self.track_history_per_model = false
      end

      def enable_tracking
        self.track_history_per_model = true
      end

      def enabled=(value)
        self.track_history_per_model = value
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