module ActiveAudit
  module ActiveRecord
    module InstanceMethods
      def audited_changes
        audit_class.where(
          'association_chain'=> {'$all' => association_chain }, 
          'scope' => audit_options[:scope]
        )
      end
      
      def audit_class
        self.class.audit_class
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

        scope = audit_options[:scope]
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

      def audited_attributes(method)
        @audited_attributes = {
          association_chain: association_chain,
          scope:             audit_options[:scope].to_s,
          action:            method,
          modifier_id:       ActiveAudit.current_modifier.id
        }

        original, modified = transform_changes(case method
          when :create
            audited_attributes_for_create
          when :destroy
            audited_attributes_for_destroy
          else
            audited_attributes_for_update
        end)

        @audited_attributes[:original] = original
        @audited_attributes[:modified] = modified
        @audited_attributes
      end

      def audited_attributes_for_create
        attributes.inject({}) do |h, pair|
          k,v  =  pair
          h[k] = [nil, v]
          h
        end.reject do |k, v|
          non_audited_columns.include?(k)
        end
      end

      def audited_attributes_for_update
        changes.except(*non_audited_columns)
      end

      def audited_attributes_for_destroy
        attributes.inject({}) do |h, pair|
          k,v  =  pair
          h[k] = [nil, v]
          h
        end
      end

      def audit_create
        return unless track_history?

        audit_class.create!(audited_attributes(:create))
      end

      def audit_update
        return unless track_history?
        return if audited_attributes_for_update.blank?
        
        audit_class.create!(audited_attributes(:update))
      end

      def audit_destroy
        return unless track_history?

        audit_class.create!(audited_attributes(:destroy))
      end
    end
  end
end