module HistoryTracker
  module ActiveRecord
    module TrackHistory
      extend ActiveSupport::Concern

      module ClassMethods
        # Track history on the given model.
        #
        # @param [ Hash ] options
        #
        # Available options:
        # scope:
        # only:
        # except:
        # parent:
        # inverse_of:
        # changes_method:
        # on:
        # class_name:

        def track_history(options = {})
          # don't allow multiple calls
          return if self.included_modules.include?(HistoryTracker::ActiveRecord::InstanceMethods)

          default_options = {
            scope:          table_name.to_s.singularize.to_sym,
            on:             [:create, :update, :destroy],
            changes_method: :changes,
          }
          options = default_options.merge(options)

          # normalize :only fields to an array of database field strings
          options[:only] = [options[:only]] unless options[:only].is_a? Array
          options[:only] = options[:only].map { |field| database_field_name(field) }.compact.uniq

          # normalize :except fields to an array of database field strings
          options[:except] = [options[:except]] unless options[:except].is_a? Array
          options[:except] = options[:except].map { |field| database_field_name(field) }.compact.uniq

          extend HistoryTracker::ActiveRecord::ClassMethods
          include HistoryTracker::ActiveRecord::InstanceMethods

          # define history_trackable_parent method
          # this method is needed when traversing association_chain
          define_method   :history_trackable_parent do
            send(options[:parent]) if options[:parent] && respond_to?(options[:parent])
          end

          delegate        :history_trackable_options, :tracked_fields, :non_tracked_fields,
                          :history_tracker_class, :track_history?,
                          to: 'self.class'

          # after_commit    :test_track
          after_create    :track_create   if options[:on].include?(:create)
          before_update   :track_update   if options[:on].include?(:update)
          before_destroy  :track_destroy  if options[:on].include?(:destroy)

          HistoryTracker.trackable_class_options ||= {}
          HistoryTracker.trackable_class_options[self.name] = options
        end
      end
    end
  end
end