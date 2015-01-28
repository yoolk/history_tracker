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
        index({ trackable_klass_name: 1 }, { background: true })

        ## Fields
        field     :association_chain,     type: Array,   default: []
        field     :original,              type: Hash,    default: {}
        field     :modified,              type: Hash,    default: {}
        field     :changeset,             type: Hash,    default: {}, as: :changes
        field     :action,                type: String
        field     :modifier_id,           type: Integer
        field     :trackable_klass_name,  type: String

        ## Validations
        validates :association_chain, :action, :modifier_id, :trackable_klass_name,
                                      presence: true
        validates :action,            inclusion: { in: [ 'create', 'update', 'destroy' ] }
        validate  :validate_original_modified_changeset

        ## Scopes
        scope     :recent,            -> { order_by(:created_at.desc) }
        scope     :updated,           -> { where(action: 'update') }
        scope     :since,             ->(time) { where(:created_at.gte => time) }
        scope     :creates,           -> { where(action: 'create') }
        scope     :updates,           -> { where(action: 'update') }
        scope     :destroys,          -> { where(action: 'destroy') }

        def original=(value)
          super(value.stringify_keys) if value.is_a?(Hash)
        end

        def modified=(value)
          super(value.stringify_keys) if value.is_a?(Hash)
        end

        def trackable
          @trackable ||= trackable_class.find(association_chain.last['id'])
        end

        def trackable_class
          @trackable_class ||= trackable_klass_name.constantize
        end

        def self.recent_updated_since(time)
          recent.updated.since(time)
        end

        private

          def validate_original_modified_changeset
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

            # TODO: validates on each field to see original and modified are really changed on update.
            errors.add(:base, 'original and modified must not be the same') if original == modified
          end
      end
    end
  end
end