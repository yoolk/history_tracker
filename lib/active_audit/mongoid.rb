require 'mongoid'

module ActiveAudit
  module Mongoid
    autoload :AuditTrail, 'active_audit/mongoid/audit_trail'
  end
end