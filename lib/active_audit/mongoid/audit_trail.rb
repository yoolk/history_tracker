module ActiveAudit
  module Mongoid
    module AuditTrail
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps
      
        field :resource_id, type: String
        field :changesets, type: Array, default: []
      end
    end
  end
end