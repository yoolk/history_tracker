require 'active_record'

module HistoryTracker
  module ActiveRecord
    autoload :InstanceMethods, 'history_tracker/active_record/instance_methods'
    autoload :ClassMethods,    'history_tracker/active_record/class_methods'
    autoload :TrackHistory,    'history_tracker/active_record/track_history'
    autoload :Extensions,      'history_tracker/active_record/extensions'
  end
end

ActiveSupport.on_load(:active_record) do
  include HistoryTracker::ActiveRecord::Extensions
  include HistoryTracker::ActiveRecord::TrackHistory
end