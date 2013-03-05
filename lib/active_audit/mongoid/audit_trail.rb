module ActiveAudit
  module Mongoid
    module AuditTrail
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps
      
        field :modifier_id,       type: String
        field :association_chain, type: Array,   default: []
        field :modified,          type: Hash,    default: {}
        field :original,          type: Hash,    default: {}
        field :version,           type: Integer
        field :action,            type: String
        field :scope,             type: String
      end
    end
  end
end