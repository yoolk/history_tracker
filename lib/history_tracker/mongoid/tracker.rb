module HistoryTracker
  module Mongoid
    module Tracker
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps

        index(scope: 1)
        index(association_chain: 1)
      
        field :scope,             type: String
        field :association_chain, type: Array,   default: []
        field :modifier_id,       type: String
        field :modifier,          type: Hash,    default: {}
        field :modified,          type: Hash,    default: {}
        field :original,          type: Hash,    default: {}
        field :changeset,         type: Hash,    default: {}
        field :action,            type: String
      end
    end
  end
end