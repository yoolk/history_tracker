require 'history_tracker/version'
require 'active_support/concern'

module HistoryTracker
  autoload :ActiveRecord,         'history_tracker/active_record'
  autoload :Mongoid,              'history_tracker/mongoid'
  autoload :Matchers,             'history_tracker/matchers'
  autoload :ControllerAdditions,  'history_tracker/controller_additions'

  class << self
    attr_accessor :ignored_tracked_fields, :trackable_class_options, :current_user_method

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

    def self.disable(&_block)
      HistoryTracker.enabled = false
      yield
    ensure
      HistoryTracker.enabled = true
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

    def current_modifier_id
      current_modifier.try(:id)
    end

    def current_modifier=(value)
      return unless value

      config_store[:current_modifier] = value
    end
  end

  @ignored_tracked_fields = %w(id lock_version created_at updated_at created_on updated_on)
  @current_user_method    = :current_user
end

require 'history_tracker/active_record'
require 'history_tracker/mongoid'
require 'history_tracker/controller_additions'

HistoryTracker.trackable_class_options = {}