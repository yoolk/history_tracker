require 'history_tracker/version'
require 'active_support/concern'

module HistoryTracker
  class << self
    attr_accessor :ignored_attributes, :current_user_method

    def current_modifier
      send("#{current_user_method}".to_sym) rescue nil
    end

    def enabled?
      enabled = Thread.current[:history_tracker_enabled]
      enabled.nil? ? true : enabled
    end

    def enabled=(value)
      Thread.current[:history_tracker_enabled] = value
    end
  end

  @ignored_attributes = %w(id lock_version created_at updated_at created_on updated_on)

  @current_user_method = :current_user
end

require 'history_tracker/active_record'
require 'history_tracker/mongoid'