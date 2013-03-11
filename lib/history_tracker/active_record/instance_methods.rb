module HistoryTracker
  module ActiveRecord
    module InstanceMethods
      def tracked_changes
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

      private
      def association_chain
        return @association_chain if @association_chain

        scope = history_options[:scope]
        if scope == self.class.name.underscore
          @association_chain = [{ id: id, name: self.class.name }]
        else
          raise "Couldn't find scope: #{scope}. Please, make sure you define this association or respond to this scope." unless respond_to?(scope)

          main = send(scope)
          reflection = main.reflections.find { |name, reflection| reflection.klass == self.class }[1]
          @association_chain = case reflection.macro
          when :has_one, :has_many
            [ { id: main.id, name: main.class.name }, { id: id, name: reflection.name.to_s } ]
          else
            # TODO:
          end
        end
        @association_chain
      end

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

      def tracked_attributes(method)
        @tracked_attributes = {
          association_chain: association_chain,
          scope:             history_options[:scope].to_s,
          action:            method,
          modifier_id:       HistoryTracker.current_modifier.id
        }

        original, modified = transform_changes(case method
          when :create
            tracked_attributes_for_create
          when :destroy
            tracked_attributes_for_destroy
          else
            tracked_attributes_for_update
        end)

        @tracked_attributes[:original] = original
        @tracked_attributes[:modified] = modified
        @tracked_attributes
      end

      def tracked_attributes_for_create
        attributes.inject({}) do |h, pair|
          k,v  =  pair
          h[k] = [nil, v]
          h
        end.reject do |k, v|
          non_tracked_columns.include?(k)
        end
      end

      def tracked_attributes_for_update
        changes.except(*non_tracked_columns)
      end

      def tracked_attributes_for_destroy
        attributes.inject({}) do |h, pair|
          k,v  =  pair
          h[k] = [nil, v]
          h
        end
      end

      def track_create
        return unless track_history?

        history_class.create!(tracked_attributes(:create))
      end

      def track_update
        return unless track_history?
        return if tracked_attributes_for_update.blank?
        
        history_class.create!(tracked_attributes(:update))
      end

      def track_destroy
        return unless track_history?

        history_class.create!(tracked_attributes(:destroy))
      end
    end
  end
end