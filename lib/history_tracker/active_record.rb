require 'active_record'

module HistoryTracker
  module ActiveRecord
    autoload :TrackHistory,    'history_tracker/active_record/track_history'
    autoload :ClassMethods,    'history_tracker/active_record/class_methods'
    autoload :InstanceMethods, 'history_tracker/active_record/instance_methods'
  end
end

::ActiveRecord::Base.send :include, HistoryTracker::ActiveRecord::TrackHistory