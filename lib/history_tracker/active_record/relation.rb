module HistoryTracker
  module ActiveRecord
    module Relation
      def history_tracks
        _scope = defined?(scoped) ? scoped : scope
        if _scope.proxy_association.owner.class.name.downcase.to_sym == history_options[:scope]
          association_chain_name = _scope.proxy_association.owner.class.name
        else
          association_chain_name = _scope.proxy_association.owner.class.name.underscore.pluralize
        end

        history_class.where(
          { 'association_chain.id'   => _scope.proxy_association.owner.id,
            'association_chain.name' => association_chain_name,
            'type'                   => _scope.proxy_association.reflection.name.to_s
          }
        )
      end
    end
  end
end