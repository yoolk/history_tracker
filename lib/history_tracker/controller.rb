module HistoryTracker
  module Controller

    def self.included(base)
      base.before_filter :set_history_tracker_enabled_for_controller
      base.before_filter :set_history_tracker_current_modifier
    end

    protected

    def user_for_history_tracker
      send(HistoryTracker.current_user_method) rescue nil
    end

    def history_tracker_enabled_for_controller
      true
    end

    private

    def set_history_tracker_enabled_for_controller
      ::HistoryTracker.enabled_for_controller = history_tracker_enabled_for_controller
    end

    def set_history_tracker_current_modifier
      ::HistoryTracker.current_modifier = user_for_history_tracker if history_tracker_enabled_for_controller
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include HistoryTracker::Controller
end