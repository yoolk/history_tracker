require 'history_tracker/version'
require 'active_support/concern'

module HistoryTracker
  class << self
    attr_accessor :ignored_attributes, :current_user_method

    def config_store
      Thread.current[:history_tracker] ||= {
        enabled: true,
        enabled_for_controller: true
      }
    end

    def enabled?
      config_store[:enabled]
    end

    def enabled=(value)
      config_store[:enabled] = value
    end

    def enabled_for_controller?
      config_store[:enabled_for_controller]
    end

    def enabled_for_controller=(value)
      config_store[:enabled_for_controller] = value
    end

    def current_modifier
      config_store[:current_modifier]
    end

    def current_modifier=(value)
      config_store[:current_modifier] = value
    end
  end

  @ignored_attributes = %w(id lock_version created_at updated_at created_on updated_on)

  @current_user_method = :current_user
end

require 'history_tracker/active_record'
require 'history_tracker/mongoid'
require 'history_tracker/controller'