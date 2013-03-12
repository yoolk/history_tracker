require 'active_record'

module HistoryTracker
  module ActiveRecord
    autoload :TrackHistory,    'history_tracker/active_record/track_history'
    autoload :ClassMethods,    'history_tracker/active_record/class_methods'
    autoload :InstanceMethods, 'history_tracker/active_record/instance_methods'
  end
end

ActiveSupport.on_load(:active_record) do
  include HistoryTracker::ActiveRecord::TrackHistory
end