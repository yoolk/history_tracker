require 'mongoid'

module ActiveAudit
  module Mongoid
    autoload :Audit, 'active_audit/mongoid/audit'
  end
end