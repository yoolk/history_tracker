module HistoryTracker
  module ActiveRecord
    module InstanceMethods
      def history_tracks
        history_class.where(
          'association_chain'=> {'$all' => association_chain }, 
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
      def tracked_changes
        tracked_changes = changes.except(*non_tracked_columns)
        include_reflections.each do |reflection|
          next if changes[reflection.foreign_key].blank?

          previous   = reflection.klass.find(changes[reflection.foreign_key][0]).attributes
          now        = send(reflection.name).attributes
          tracked_changes[reflection.name] = [previous, now]
        end
        
        tracked_changes
      end

      def original_attributes
        original = attributes.merge(changed_attributes)
        include_reflections.each do |reflection|
          if changes[reflection.foreign_key].present?
            original[reflection.name] = reflection.klass.find(changes[reflection.foreign_key][0]).attributes
          else
            original[reflection.name] = send(reflection.name).attributes
          end
        end

        original
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
        
        tracked_attributes_hash[:original] = original
        tracked_attributes_hash[:modified] = modified
        tracked_attributes_hash[:changeset] = changeset
        tracked_attributes_hash
      end

      def tracked_attributes_for_create
        original  = {}
        modified  = attributes.except(*non_tracked_columns).reject { |k, v| v.nil? }
        include_reflections.each do |reflection|
          modified[reflection.name] = send(reflection.name).attributes
        end
        changeset = modified.inject({}) do |h, pair|
          k,v  =  pair
          h[k] = [nil, v]
          h
        end

        [original, modified, changeset]
      end

      def tracked_attributes_for_update
        original  = original_attributes
        changeset = tracked_changes
        modified  = changeset.inject({}) do |h, pair|
          k,v = pair
          h[k] = v[1]
          h
        end

        [original, modified, changeset]
      end

      def tracked_attributes_for_destroy
        [original_attributes, {}, {}]
      end

      def track_create
        return unless track_history?

        write_track(:create)
      end

      def track_update
        return unless track_history?
        
        write_track(:update)
      end

      def track_destroy
        return unless track_history?

        write_track(:destroy)
      end

      def write_track(method)
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