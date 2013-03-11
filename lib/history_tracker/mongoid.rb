require 'mongoid'

module HistoryTracker
  module Mongoid
    autoload :Tracker, 'history_tracker/mongoid/tracker'
  end
end