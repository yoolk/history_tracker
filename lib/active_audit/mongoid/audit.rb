module ActiveAudit
  module Mongoid
    class Audit
      include ::Mongoid::Document
      include ::Mongoid::Timestamps

      field :resource_id, type: String
      field :change_sets, type: Array, default: []

      class_attribute :audited_class_names,
                      instance_reader: false, instance_writer: false
      self.audited_class_names = []

      def audited_classes
        audited_class_names.map(&:constantize)
      end
    end
  end
end