module HistoryTracker
  module Mongoid
    module Tracker
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps

        ## Indexes
        index({ 'association_chain.id' => 1, 'association_chain.name' => 1}, { background: true })
        index({ modifier_id: 1 }, { background: true })
        index({ trackable_class_name: 1 }, { background: true })

        ## Fields
        field     :association_chain,     type: Array,   default: []
        field     :original,              type: Hash,    default: {}
        field     :modified,              type: Hash,    default: {}
        field     :action,                type: String
        field     :modifier_id,           type: String
        field     :trackable_class_name,  type: String

        ## Validations
        validates :association_chain, :action, :modifier_id, :trackable_class_name,
                                      presence: true
        validates :action,            inclusion: { in: [ 'create', 'update', 'destroy' ] }
        validate  :validate_original_modified

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

          def validate_original_modified
            case action
            when 'create'
              errors.add(:original, 'must be blank')      if original.present?
              errors.add(:modified, 'must not be blank')  if modified.blank?
            when 'update'
              errors.add(:original, 'must not be blank')  if original.blank?
              errors.add(:modified, 'must not be blank')  if modified.blank?
            when 'destroy'
              errors.add(:original, 'must not be blank')  if original.blank?
              errors.add(:modified, 'must be blank')      if modified.present?
            end

            ## stringify keys before save and compare
            errors.add(:base, 'original and modified must not be the same') if original == modified
          end
      end
    end
  end
end