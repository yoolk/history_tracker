module HistoryTracker
  module Mongoid
    module Tracker
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps

        index({ scope: 1 }, { background: true })
        index({ type: 1 }, { background: true })
        index({ 'association_chain.id' => 1,  'association_chain.name' => 1}, { background: true })
        index({ modifier: 1 }, { background: true })

        field :scope,             type: String
        field :association_chain, type: Array,   default: []
        field :modifier,          type: Hash,    default: {}
        field :original,          type: Hash,    default: {}
        field :modified,          type: Hash,    default: {}
        field :changeset,         type: Hash,    default: {}
        field :type,              type: String
        field :action,            type: String

        validates :scope, :association_chain, :action, :type, presence: true
        validates :action, inclusion: { in: [ 'create', 'update', 'destroy' ] }
        validate  :validate_original_modified_and_changeset

        scope :recent, lambda { order_by(:created_at.desc) }
        scope :updated, lambda { where(action: 'update') }
        scope :since, lambda { |time| where(:created_at.gte => time) }

        def self.recent_updated_since(time)
          recent.updated.since(time)
        end

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