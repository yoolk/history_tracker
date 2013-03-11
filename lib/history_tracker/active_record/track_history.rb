module HistoryTracker
  module ActiveRecord
    module TrackHistory
      extend ActiveSupport::Concern

      module ClassMethods
        def track_history(options = {})
          return if track?

          options[:scope] ||= self.name.underscore
          class_attribute :history_options, instance_writer: false
          self.history_options = options

          delegate :track_history?, :to => 'self.class'
          class_attribute :track_history_per_model, instance_writer: false
          self.track_history_per_model = true

          setup_tracking!

          extend HistoryTracker::ActiveRecord::ClassMethods
          include HistoryTracker::ActiveRecord::InstanceMethods
        end

        def track?
          self.included_modules.include?(HistoryTracker::ActiveRecord::InstanceMethods)
        end

        private
        def setup_tracking!
          track_column!
          track_callback!
        end

        def track_column!
          class_attribute :tracked_columns, instance_writer: false
          class_attribute :non_tracked_columns, instance_writer: false

          if history_options[:only]
            except = column_names - history_options[:only].flatten.map(&:to_s)
          else
            except = HistoryTracker.ignored_attributes
            except |= Array(history_options[:except]).collect(&:to_s) if history_options[:except]
          end
          self.non_tracked_columns = except
          self.tracked_columns     = column_names - except
        end

        def track_callback!
          after_create   :track_create   if !history_options[:on] || (history_options[:on] && history_options[:on].include?(:create))
          before_update  :track_update   if !history_options[:on] || (history_options[:on] && history_options[:on].include?(:update))
          before_destroy :track_destroy  if !history_options[:on] || (history_options[:on] && history_options[:on].include?(:destroy))
        end
      end
    end
  end
end