module HistoryTracker
  module Mongoid
    module Tracker
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps

        index(scope: 1)
        index(association_chain: 1)
        index(modifier_id: 1)
      
        field :scope,             type: String
        field :association_chain, type: Array,   default: []
        field :modifier,          type: Hash,    default: {}
        field :original,          type: Hash,    default: {}
        field :modified,          type: Hash,    default: {}
        field :changeset,         type: Hash,    default: {}
        field :action,            type: String

        validates :scope, :association_chain, :action, presence: true
        validate :validate_original_modified_and_changeset

        private
        def validate_original_modified_and_changeset
          case action
          when 'create'
            errors.add(:original, 'attributes should be blank') if original.present?
            errors.add(:modified, 'attributes should not be blank') if modified.blank?
            errors.add(:changeset, 'should not be blank') if changeset.blank?
          when 'update'
            errors.add(:original, 'attributes should not be blank') if original.blank?
            errors.add(:modified, 'attributes should not be blank') if modified.blank?
            errors.add(:changeset, 'should not be blank') if changeset.blank?
          when 'destroy'
            errors.add(:original, 'attributes should not be blank') if original.blank?
            errors.add(:modified, 'attributes should be blank') if modified.present?
            errors.add(:changeset, 'should be blank') if changeset.present?
          end
        end
      end
    end
  end
end