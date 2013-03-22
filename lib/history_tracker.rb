require 'history_tracker/version'
require 'active_support/concern'

module HistoryTracker
  class << self
    attr_accessor :ignored_attributes, :current_user_method, :current_user_fields

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
      modifier = if config_store[:current_modifier]
        config_store[:current_modifier]
      else
        {}
      end
    end

    def current_modifier=(value)
      config_store[:current_modifier] = value.attributes.slice(*current_user_fields)
    end
  end

  @ignored_attributes  = %w(id lock_version created_at updated_at created_on updated_on)

  @current_user_method = :current_user

  @current_user_fields = ['id', 'email']
end

require 'history_tracker/active_record'
require 'history_tracker/mongoid'
require 'history_tracker/controller'