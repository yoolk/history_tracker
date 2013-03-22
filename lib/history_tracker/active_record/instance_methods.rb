module HistoryTracker
  module ActiveRecord
    module InstanceMethods
      def history_tracks
        history_class.where(
          'association_chain' => { '$all' => association_chain }, 
          'scope' => history_options[:scope]
        )
      end
      
      def history_class
        self.class.history_class
      end

      def without_tracking(method = nil)
        tracking_was_enabled = self.track_history_per_model
        self.class.disable_tracking
        method ? method.to_proc.call(self) : yield
      ensure
        self.class.enable_tracking if tracking_was_enabled
      end

      def association_chain
        return @association_chain if @association_chain

        scope = history_options[:scope]

        if scope.to_s == self.class.name.split('::').last.underscore
          @association_chain = [{ id: id, name: self.class.name }]
        else
          if self.class.reflect_on_association(history_options[:scope])
            main = send(scope)
            reflection = main.reflections.find { |name, reflection| reflection.klass == self.class }[1]
            @association_chain = case reflection.macro
            when :has_one, :has_many
              [ { id: main.id, name: main.class.name }, { id: id, name: reflection.name.to_s } ]
            else
              # TODO:
            end
          elsif history_options[:association_chain].present?
            @association_chain = history_options[:association_chain].call(self)
          else
            raise "Couldn't find scope: #{scope}. Please, make sure you define this association." 
          end
        end
        @association_chain
      end

      private
      def original_modified_and_changeset
        original  = attributes.merge(changed_attributes)
        modified  = attributes.except(*non_tracked_columns).reject { |k, v| v.nil? }
        changeset = changes.except(*non_tracked_columns)
        history_options[:include].each do |pair|
          if pair.is_a?(Hash)
            association_name, association_fields = pair.keys.first, pair.values.first
          else
            association_name, association_fields = pair, nil
          end

          reflection = self.class.reflect_on_association(association_name)
          now        = send(reflection.name)
          association_fields ||= now.attributes.keys
          if changes[reflection.foreign_key] and changes[reflection.foreign_key][0].present?
            previous = reflection.klass.find(changes[reflection.foreign_key][0])
            association_fields.each do |field|
              field_name = "#{reflection.name}_#{field}"
              original[field_name]  = previous.send(field)
              modified[field_name]  = now.send(field)
              changeset[field_name] = [previous.send(field), now.send(field)]
            end
          else
            association_fields.each do |field|
              field_name = "#{reflection.name}_#{field}"
              original[field_name]  = now.send(field)
              modified[field_name]  = now.send(field)
              changeset[field_name] = [nil, now.send(field)]
            end
          end
        end
        
        [original, modified, changeset]
      end

      def tracked_attributes_for(method)
        tracked_attributes_hash = {
          association_chain: association_chain,
          scope:             history_options[:scope].to_s,
          action:            method,
          modifier:          HistoryTracker.current_modifier
        }
        
        original, modified, changeset = case method
          when :create
            tracked_attributes_for_create
          when :update
            tracked_attributes_for_update
          when :destroy
            tracked_attributes_for_destroy
        end
        
        tracked_attributes_hash[:original]  = original
        tracked_attributes_hash[:modified]  = modified
        tracked_attributes_hash[:changeset] = changeset
        tracked_attributes_hash
      end

      def tracked_attributes_for_create
        original, modified, changeset = original_modified_and_changeset

        [{}, modified, changeset]
      end

      def tracked_attributes_for_update
        original, modified, changeset = original_modified_and_changeset
        modified  = changeset.inject({}) do |h, pair|
          k,v = pair
          h[k] = v[1]
          h
        end

        [original, modified, changeset]
      end

      def tracked_attributes_for_destroy
        [original_modified_and_changeset[0], {}, {}]
      end

      def track_create
        return unless track_history?

        write_history_track(:create)
      end

      def track_update
        return unless track_history?
        
        write_history_track(:update)
      end

      def track_destroy
        return unless track_history?

        write_history_track(:destroy)
      end

      def write_history_track(method)
        begin
          tracked_attributes = tracked_attributes_for(method)
          return if method.in?([:create, :update]) and tracked_attributes[:modified].blank? and tracked_attributes[:changeset].blank?

          history_class.create!(tracked_attributes)
        rescue
          errors.add(:base, 'could not save the changes inside the history tracker') and raise
        end
      end
    end
  end
end