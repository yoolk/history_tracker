module HistoryTracker
  module ActiveRecord
    module InstanceMethods
      def history_tracks(options = {})
        scope = options[:scope] ||= false
        history_class.where(
          build_query_conditions(scope)
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

        history_scope = history_options[:scope]
        if history_scope.to_s == self.class.name.split('::').last.underscore
          @association_chain = [{ id: id, name: self.class.name.gsub(/^Yoolk::/, "") }]
        else
          if history_options[:association_chain].present?
            @association_chain = history_options[:association_chain].call(self)
          elsif self.class.reflect_on_association(history_scope)
            main = send(history_scope)
            reflection = main.reflections.find { |name, reflection| reflection.klass == self.class }[1]
            @association_chain = case reflection.macro
            when :belongs_to, :has_one, :has_many
              [ { id: main.id, name: main.class.name.gsub(/^Yoolk::/, "") }, { id: id, name: reflection.name.to_s } ]
            else
              # TODO:
            end
          else
            raise "Couldn't find scope: #{history_scope}. Please, make sure you define this association."
          end
        end
        @association_chain
      end

      def create_history_track!(method, changeset, modifier=HistoryTracker.current_modifier)
        original = tracked_original_attributes
        modified = {}
        changeset.each do |k, pair|
          original[k] = pair[0] if original.key?(k)
          modified[k] = pair[1] unless pair[1].nil?
        end

        tracked_attributes = {
          modifier:          modifier,
          association_chain: association_chain,
          scope:             history_options[:scope].to_s,
          type:              association_chain.last[:name],
          action:            method,
          original:          (method.to_s == 'create') ? {} : original,
          changeset:         (method.to_s == 'destroy') ? {} : changeset,
          modified:          (method.to_s == 'destroy') ? {} : modified
        }

        begin
          history_class.create!(tracked_attributes)
        rescue
          errors.add(:base, 'could not save in the history tracker') and raise
        end
      end

      private
      def tracked_original_attributes
        original = attributes.merge(changed_attributes)
        only     = history_options[:only] + ['id', 'created_at', 'updated_at']

        if history_options[:only].present?
          original.select { |k, v| only.include?(k) }
        else
          original.except(*history_options[:except])
        end
      end

      def tracked_attributes_for_create
        original  = {}
        changeset = changes.except(*non_tracked_columns)
        modified  = changeset.inject({}) do |h, pair|
          k,v = pair
          h[k] = v[1]
          h
        end
        included  = tracked_attributes_from_include(:create)

        [original.merge(included[0]), modified.merge(included[1]), changeset.merge(included[2])]
      end

      def tracked_attributes_for_update
        original  = tracked_original_attributes
        changeset = changes.except(*non_tracked_columns)
        modified  = changeset.inject({}) do |h, pair|
          k,v = pair
          h[k] = v[1]
          h
        end
        included  = tracked_attributes_from_include(:update)

        [original.merge(included[0]), modified.merge(included[1]), changeset.merge(included[2])]
      end

      def tracked_attributes_for_destroy
        original  = tracked_original_attributes
        history_options[:methods].each do |method|
          original["#{method}"] = send(method)
        end
        changeset = {}
        modified  = {}

        included  = tracked_attributes_from_include(:destroy)

        [original.merge(included[0]), modified.merge(included[1]), changeset.merge(included[2])]
      end

      def tracked_attributes_from_include(method)
        original  = {}
        modified  = {}
        changeset = {}

        include_reflections.each do |item|
          reflection = item.keys.first
          now        = send(reflection.name)
          next if now.nil?

          fields     = item.values.first || now.attribute_names

          if method == :create
            fields.each do |field|
              field_name = "#{reflection.name}_#{field}"
              modified[field_name]  = now.send(field)
              changeset[field_name] = [nil, now.send(field)]
            end
          elsif method == :update
            if changes[reflection.foreign_key] and changes[reflection.foreign_key][0].present?
              previous = reflection.klass.find(changes[reflection.foreign_key][0])
              fields.each do |field|
                field_name = "#{reflection.name}_#{field}"
                original[field_name]  = previous.send(field)
                modified[field_name]  = now.send(field)
                changeset[field_name] = [previous.send(field), now.send(field)]
              end
            else
              fields.each do |field|
                field_name = "#{reflection.name}_#{field}"
                original[field_name]  = now.send(field)
              end
            end
          elsif method == :destroy
            fields.each do |field|
              field_name = "#{reflection.name}_#{field}"
              original[field_name]  = now.send(field)
            end
          end
        end

        [original, modified, changeset]
      end

      def tracked_attributes_for(method)
        tracked_attributes_hash = {
          association_chain: association_chain,
          scope:             history_options[:scope].to_s,
          type:              association_chain.last[:name],
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
          if changeset_lambda  = history_options[:changeset]
            tracked_attributes = send(changeset_lambda, method).delete_if { |field, value| value[0].blank? and value[1].blank? }
            return if method.in?([:create, :update]) and tracked_attributes.blank?

            create_history_track!(method, tracked_attributes)
          else
            tracked_attributes = tracked_attributes_for(method)
            return if method.in?([:create, :update]) and tracked_attributes[:modified].blank? and tracked_attributes[:changeset].blank?

            history_class.create!(tracked_attributes)
          end
          # create_history_track!(method, tracked_attributes)
        rescue
          errors.add(:base, 'could not save in the history tracker') and raise
        end
      end

      def build_query_conditions(scope)
        history_scope = history_options[:scope]
        association_chain = if history_scope.to_s == self.class.name.split('::').last.underscore
          single_association_chain
        else
          if history_options[:association_chain].present?
            custom_assciation_chains
          elsif self.class.reflect_on_association(history_scope)
            multi_association_chains
          else
            raise "Couldn't find scope: #{history_scope}. Please, make sure you define this association."
          end
        end

        if scope
          association_chain['scope'] = history_options[:scope]
        else
          association_chain['type'] = association_chain['association_chain.name']
        end
        association_chain
      end

      def single_association_chain
        { 'association_chain.id'   => id, 'association_chain.name' => self.class.name }
      end

      def multi_association_chains
        main = send(history_options[:scope])
        reflection = main.reflections.find { |name, reflection| reflection.klass == self.class }[1]
        association_chain = case reflection.macro
        when :belongs_to, :has_one, :has_many
          { 'association_chain.id' => id, 'association_chain.name' => reflection.name.to_s }
        else
          {}
        end
      end

      def custom_assciation_chains
        association_chain = history_options[:association_chain].call(self).last
        { 'association_chain.id'   => association_chain[:id], 'association_chain.name' => association_chain[:name] }
      end

    end
  end
end