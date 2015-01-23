module HistoryTracker
  module ActiveRecord
    module InstanceMethods

      def association_chain
        traverse_association_chain(self)
      end

      def history_tracks
        @history_tracks ||= history_tracker_class.where(scope: related_scope, association_chain: association_hash)
      end

      protected

        def track_history_for_action?(action)
          track_history? && !(action.to_sym == :update && modified_attributes_for_update.blank?)
        end

      private

        def traverse_association_chain(node = self)
          list = node.history_trackable_parent ? traverse_association_chain(node.history_trackable_parent) : []
          list << association_hash(node)
          list
        end

        def association_hash(node = self)
          if node.history_trackable_parent
            meta = node.history_trackable_parent.class.reflections.values.select do |relation|
              relation.name == node.history_trackable_options[:inverse_of] &&
              relation.class_name == node.class.name
            end.first
          end

          # if root node has no meta, and should use class name instead
          name = meta ? meta.name.to_s : node.class.name

          ActiveSupport::OrderedHash['name', name, 'id', node.id]
        end

        def related_scope
          scope = history_trackable_options[:scope]
          scope = history_trackable_options[:parent] if history_trackable_parent.present?
          scope
        end

        # Retrieves the modified attributes for create action
        #
        # Returns hash which contains field as key and [nil, value] as value
        # Eg: {"name"=>[nil, "Listing 1"], "description"=> [nil, "Description 1"]}
        def modified_attributes_for_create
          @modified_attributes_for_create ||= attributes.inject({}) do |h, (k, v)|
            h[k] = [nil, v]
            h
          end.select { |k, _| self.class.tracked_field?(k, :create) }
        end

        # Retrieves the modified attributes for update action
        #
        # Returns hash which contains field as key and [old_value, new_value] as value
        # Eg: {"name"=>["Old Listing", "Listing 1"], "description"=> ["Old Description", "Description 1"]}
        def modified_attributes_for_update
          @modified_attributes_for_update ||= send(history_trackable_options[:changes_method]).select { |k, _| self.class.tracked_field?(k, :update) }
        end

        # Retrieves the modified attributes for destroy action
        #
        # Returns hash which contains field as key and [value, nil] as value
        # Eg: {"name"=>["Listing 1", nil], "description"=> ["Description 1", nil]}
        def modified_attributes_for_destroy
          @modified_attributes_for_destroy ||= attributes.inject({}) do |h, (k, v)|
            h[k] = [v, nil]
            h
          end.select { |k, _| self.class.tracked_field?(k, :destroy) }
        end

        # Returns a Hash of field name to pairs of original and modified values
        # for each tracked field for a given action.
        #
        # @param [ String | Symbol ] action The modification action (:create, :update, :destroy)
        #
        # @return [ Hash<String, Array<Object>> ] the pairs of original and modified
        #   values for each field
        def modified_attributes_for_action(action)
          case action.to_sym
          when :destroy then modified_attributes_for_destroy
          when :create then modified_attributes_for_create
          else modified_attributes_for_update
          end
        end

        # Attributes for history tracker model
        #
        # Returns hash of attributes before saved to tracker model
        def history_tracker_attributes(action)
          return @history_tracker_attributes if @history_tracker_attributes

          @history_tracker_attributes = {
            association_chain: traverse_association_chain,
            scope: related_scope
          }

          changeset          = modified_attributes_for_action(action)
          original, modified = transform_changes(changeset)

          @history_tracker_attributes[:original]  = original
          @history_tracker_attributes[:modified]  = modified
          @history_tracker_attributes[:changeset] = changeset
          @history_tracker_attributes
        end


        # Returns an array of original and modified from changeset
        #
        def transform_changes(changes)
          original = {}
          modified = {}
          changes.each_pair do |k, v|
            o, m = v
            original[k] = o unless o.nil?
            modified[k] = m unless m.nil?
          end

          [original, modified]
        end

        def track_history_for_action(action)
          if track_history_for_action?(action)
            history_tracker_class.create!(history_tracker_attributes(action.to_sym).merge(action: action.to_s))
          end
          clear_trackable_memoization
        end

        def track_create
          track_history_for_action(:create)
        end

        def track_update
          track_history_for_action(:update)
        end

        def track_destroy
          track_history_for_action(:destroy)
        end

        def clear_trackable_memoization
          @history_tracker_attributes     =  nil
          @modified_attributes_for_create = nil
          @modified_attributes_for_update = nil
          @history_tracks                 = nil
        end
    end
  end
end