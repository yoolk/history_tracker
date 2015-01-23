module HistoryTracker
  module Mongoid
    module Tracker
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps

        ## Indexes
        index({ scope: 1 }, { background: true })
        index({ 'association_chain.id' => 1, 'association_chain.name' => 1}, { background: true })
        index({ modifier_id: 1 }, { background: true })

        ## Fields
        field     :scope,             type: String
        field     :association_chain, type: Array,   default: []
        field     :original,          type: Hash,    default: {}
        field     :modified,          type: Hash,    default: {}
        field     :changeset,         type: Hash,    default: {}
        field     :action,            type: String

        ## Relations
        belongs_to :modifier,         class_name: HistoryTracker.modifier_class_name

        ## Validations
        validates :scope, :association_chain, :action,
                                      presence: true
        validates :action,            inclusion: { in: [ 'create', 'update', 'destroy' ] }
        validate  :validate_original_modified_and_changeset

        ## Scopes
        scope     :recent,            -> { order_by(:created_at.desc) }
        scope     :updated,           -> { where(action: 'update') }
        scope     :since,             ->(time) { where(:created_at.gte => time) }
        scope     :creates,           -> { where(action: 'create') }
        scope     :updates,           -> { where(action: 'update') }
        scope     :destroys,          -> { where(action: 'destroy') }

        def self.recent_updated_since(time)
          recent.updated.since(time)
        end

        private

          def validate_original_modified_and_changeset
            case action
            when 'create'
              errors.add(:original, 'must be blank')      if original.present?
              errors.add(:modified, 'must not be blank')  if modified.blank?
              errors.add(:changeset, 'must not be blank') if changeset.blank?
            when 'update'
              errors.add(:original, 'must not be blank')  if original.blank?
              errors.add(:modified, 'must not be blank')  if modified.blank?
              errors.add(:changeset, 'must not be blank') if changeset.blank?
            when 'destroy'
              errors.add(:original, 'must not be blank')  if original.blank?
              errors.add(:modified, 'must be blank')      if modified.present?
              errors.add(:changeset, 'must be blank')     if changeset.present?
            end
          end
      end
    end
  end
end