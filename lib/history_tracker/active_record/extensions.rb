module HistoryTracker
  module ActiveRecord
    module Extensions
      extend ActiveSupport::Concern

      included do
        def database_field_name(name)
          self.class.database_field_name(name)
        end
      end

      module ClassMethods
        def database_field_name(name)
          return nil unless name
          normalized = name.to_s
          return normalized if normalized.in?(column_names)

          reflection = reflect_on_association(name.to_sym)
          return reflection.foreign_key.to_s if reflection.try(:macro) == :belongs_to
        end
      end
    end
  end
end