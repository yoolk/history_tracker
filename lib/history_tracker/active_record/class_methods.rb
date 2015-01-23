module HistoryTracker
  module ActiveRecord
    module ClassMethods

      def history_trackable_options
        @history_trackable_options ||= HistoryTracker.trackable_class_options[self.name]
      end

      def history_tracker_class
        return @history_tracker_class if @history_tracker_class

        h = history_trackable_options
        if h[:class_name].present?
          klass = h[:class_name].constantize
        elsif scope_reflection.present?
          klass = scope_reflection.klass.history_tracker_class
        else
          klass_name  = "#{self.name}HistoryTracker"
          klass       = self.const_get(klass_name) rescue nil

          if klass.nil?
            collection_name = self.table_name.singularize + '_histories'
            klass = Class.new do
              include HistoryTracker::Mongoid::Tracker
              store_in collection: collection_name
            end
            klass = Object.const_set(klass_name, klass)
          end
        end

        @history_tracker_class = klass
      end

      def scope_reflection
        reflect_on_association(history_trackable_options[:scope])
      end

      def tracked_fields
        @tracked_fields ||= (column_names - non_tracked_fields)
      end

      def non_tracked_fields
        return @non_tracked_fields if @non_tracked_fields

        h = history_trackable_options
        if h[:only].present?
          except = column_names - h[:only]
        else
          except = ignored_tracked_fields
          except |= h[:except] if h[:except].present?
        end

        @non_tracked_fields = except
      end

      # Returns the ignored tracked fields.
      # By default, it returns from the `HistoryTracker` module. Each class could override here.
      #
      # @return [ Array ] the list of fields that are ignored for trackings.
      def ignored_tracked_fields
        @ignored_tracked_fields ||= HistoryTracker.ignored_tracked_fields
      end

      # Whether or not the field should be tracked.
      #
      # @param [ String | Symbol ] field The name or alias of the field
      # @param [ String | Symbol ] action The optional action name (:create, :update, or :destroy)
      #
      # @return [ Boolean ] whether or not the field is tracked for the given action
      def tracked_field?(field, action = :update)
        tracked_fields_for_action(action).include? database_field_name(field)
      end

      # Retrieves the list of tracked fields for a given action.
      #
      # @param [ String | Symbol ] action The action name (:create, :update, or :destroy)
      #
      # @return [ Array < String > ] the list of tracked fields for the given action
      def tracked_fields_for_action(action)
        case action.to_sym
        when :destroy then tracked_fields + ignored_tracked_fields
        else tracked_fields
        end
      end

      def track_history?
        HistoryTracker.enabled? && HistoryTracker.enabled_for_controller? && Thread.current[track_history_flag] != false
      end

      def disable_tracking(&_block)
        Thread.current[track_history_flag] = false
        yield
      ensure
        Thread.current[track_history_flag] = true
      end

      def track_history_flag
        "#{name}_history_trackable_enabled".to_sym
      end
    end
  end
end