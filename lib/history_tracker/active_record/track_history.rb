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
            on:             [:create, :update, :destroy],
            changes_method: :changes,
          }
          options = default_options.merge(options)

          # make :only and :except are array
          options[:only]    = [options[:only]]     unless options[:only].is_a? Array
          options[:except]  = [options[:except]]   unless options[:except].is_a? Array

          # validate :parent and :inverse_of
          if options[:parent].present?
            parent_reflection     = reflect_on_association(options[:parent])
            parent_klass          = parent_reflection.klass
            inverse_of_reflection = parent_klass.try(:reflect_on_association, options[:inverse_of])

            raise "Couldn't find parent relation :#{options[:parent]} on #{self.name}."             if parent_klass.nil?
            raise "Couldn't find inverse_of relation :#{options[:inverse_of]} on #{parent_klass}."  if inverse_of_reflection.nil?
          end

          # define history_trackable_parent method
          # this method is needed when traversing association_chain
          define_method   :history_trackable_parent do
            send(options[:parent]) if options[:parent] && respond_to?(options[:parent])
          end

          # makes these methods available on class/instance
          delegate        :history_trackable_options, :tracked_fields, :non_tracked_fields,
                          :history_tracker_class, :track_history?,
                          to: 'self.class'

          # http://guides.rubyonrails.org/v4.0.12/active_record_callbacks.html#transaction-callbacks
          # after_commit      :track_create,  on: :create     if options[:on].include?(:create)
          # after_commit      :track_update,  on: :update     if options[:on].include?(:update)
          # after_commit      :track_destroy, on: :destroy    if options[:on].include?(:destroy)

          after_create    :track_create   if options[:on].include?(:create)
          before_update   :track_update   if options[:on].include?(:update)
          before_destroy  :track_destroy  if options[:on].include?(:destroy)

          extend HistoryTracker::ActiveRecord::ClassMethods
          include HistoryTracker::ActiveRecord::InstanceMethods

          HistoryTracker.trackable_class_options ||= {}
          HistoryTracker.trackable_class_options[self.name] = options
        end
      end
    end
  end
end