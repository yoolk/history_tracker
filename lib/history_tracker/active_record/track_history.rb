module HistoryTracker
  module ActiveRecord
    module TrackHistory
      extend ActiveSupport::Concern

      module ClassMethods
        def track_history(options = {})
          return if track?

          delegate :track_history?, :to => 'self.class'
          class_attribute :track_history_per_model, instance_writer: false
          self.track_history_per_model = true

          setup_tracking!(options)

          extend HistoryTracker::ActiveRecord::ClassMethods
          include HistoryTracker::ActiveRecord::InstanceMethods
        end

        def track?
          self.included_modules.include?(HistoryTracker::ActiveRecord::InstanceMethods)
        end

        private
        def setup_tracking!(options)
          track_options!(options)
          track_column!
          track_callback!
        end

        def track_options!(options)
          options[:scope]   ||= self.name.underscore
          options[:except]  ||= []
          options[:only]    ||= []
          options[:include] ||= []

          includes, except    = [], []
          options[:include].each do |association|
            reflection = reflect_on_association(association)
            next if reflection.try(:macro) != :belongs_to

            includes << association
            except   << reflection.foreign_key
          end

          class_attribute :history_options, instance_writer: false
          self.history_options = options
          self.history_options[:include] = includes
          self.history_options[:except] += except
        end

        def track_column!
          class_attribute :tracked_columns, instance_writer: false
          class_attribute :non_tracked_columns, instance_writer: false

          if history_options[:only].present?
            except = column_names - history_options[:only].flatten.map(&:to_s)
          else
            except = HistoryTracker.ignored_attributes
            except |= history_options[:except].collect(&:to_s) if history_options[:except]
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