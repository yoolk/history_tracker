require 'active_record'

module ActiveAudit
  module ActiveRecord
    autoload :ActMacro,        'active_audit/active_record/act_macro'
    autoload :ClassMethods,    'active_audit/active_record/class_methods'
    autoload :InstanceMethods, 'active_audit/active_record/instance_methods'
  end
end

::ActiveRecord::Base.send :include, ActiveAudit::ActiveRecord::ActMacro