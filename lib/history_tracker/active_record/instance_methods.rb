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
        if scope == self.class.name.underscore
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
      def transform_changes(changes)
        original = {}
        modified = {}
        changes.each_pair do |k, v|
          o, m = v
          original[k] = o unless o.nil?
          modified[k] = m unless m.nil?
        end

        [ original, modified ]
      end

      def tracked_attributes
        tracked_attributes = attributes
        history_options[:include].each do |association|
          tracked_attributes[association] = send(association).attributes
        end

        tracked_attributes
      end

      def original_attributes
        original_attributes = attributes.merge(changed_attributes)
        history_options[:include].each do |association|
          reflection = self.class.reflect_on_association(association)
          previous   = reflection.klass.find(changes[reflection.foreign_key][0]).attributes

          original_attributes[association] = previous
        end

        original_attributes
      end

      def tracked_attributes_for(method)
        tracked_attributes_hash = {
          association_chain: association_chain,
          scope:             history_options[:scope].to_s,
          action:            method,
          modifier:          HistoryTracker.current_modifier.try(:attributes),
          modifier_id:       HistoryTracker.current_modifier.try(:id)
        }

        tracked_changes = case method
          when :create
            tracked_attributes_for_create
          when :destroy
            tracked_attributes_for_destroy
          else
            tracked_attributes_for_update
        end
        
        original, modified = transform_changes(tracked_changes)
        tracked_attributes_hash[:original] = (method == :update) ? original_attributes : original
        tracked_attributes_hash[:modified] = modified
        tracked_attributes_hash[:changeset] = (method == :destroy) ? {} : tracked_changes
        tracked_attributes_hash
      end

      def tracked_attributes_for_create
        tracked_attributes.inject({}) do |h, pair|
          k,v  =  pair
          h[k] = [nil, v]
          h
        end.reject do |k, v|
          non_tracked_columns.include?(k)
        end
      end

      def tracked_attributes_for_update
        tracked_changes = changes.except(*non_tracked_columns)
        history_options[:include].each do |association|
          reflection = self.class.reflect_on_association(association)
          previous   = reflection.klass.find(changes[reflection.foreign_key][0]).attributes
          now        = send(association).attributes
        
          tracked_changes[reflection.name] = [previous, now]
        end
        
        tracked_changes
      end

      def tracked_attributes_for_destroy
        tracked_attributes.inject({}) do |h, pair|
          k,v  =  pair
          h[k] = [v,nil]
          h
        end
      end

      def track_create
        return unless track_history?

        history_class.create!(tracked_attributes_for(:create))
      end

      def track_update
        return unless track_history?
        return if tracked_attributes_for_update.blank?
        
        history_class.create!(tracked_attributes_for(:update))
      end

      def track_destroy
        return unless track_history?

        history_class.create!(tracked_attributes_for(:destroy))
      end
    end
  end
end