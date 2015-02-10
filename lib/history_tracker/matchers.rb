module HistoryTracker
  module Matchers
    # Ensure that the model is tracked history.
    #
    # Options:
    # * <tt>class_name</tt>
    # * <tt>only</tt>
    # * <tt>except</tt>
    # * <tt>parent</tt>
    # * <tt>inverse_of</tt>
    # * <tt>changes_method</tt>
    # * <tt>on</tt>
    #
    # Example:
    #   it { should be_tracked_history }
    #   it { should be_tracked_history.only(:field_name) }
    #   it { should be_tracked_history.except(:password) }
    #   it { should be_tracked_history.parent(:listing).inverse_of(:communications) }
    #   it { should be_tracked_history.on(:create) }
    #   it { should be_tracked_history.changes_method(:changes) }
    #   it { should be_tracked_history.class_name('ListingHistoryTracker') }
    #
    def be_tracked_history
      TrackedHistoryMatcher.new
    end

    class TrackedHistoryMatcher
      def initialize
        @options = {}
      end

      def only(*fields)
        @options[:only] = fields.flatten
        self
      end

      def except(*fields)
        @options[:except] = fields.flatten
        self
      end

      def parent(parent)
        @options[:parent] = parent
        self
      end

      def inverse_of(inverse_of)
        @options[:inverse_of] = inverse_of
        self
      end

      def on(*actions)
        @options[:on] = actions.flatten
        self
      end

      def changes_method(changes_method)
        @options[:changes_method] = changes_method
        self
      end

      def class_name(class_name)
        @options[:class_name] = class_name
        self
      end

      def matches?(subject)
        @subject = subject
        tracking_history_enabled? &&
          parent_options? &&
          inverse_of_options? &&
          only_options? &&
          except_options? &&
          changes_method_options? &&
          on_options? &&
          class_name_options?
      end

      def failure_message
        "Expected #{@expectation}"
      end

      def failure_message_when_negated
        "Did not expect #{@expectation}"
      end

      def description
        description = "tracked history"
        description += " only => #{@options[:only].join ', '}"          if @options.key?(:only)
        description += " except => #{@options[:except].join(', ')}"     if @options.key?(:except)

        description
      end

      protected

        def expects(message)
          @expectation = message
        end

        def model_class
          @subject.class
        end

        def history_trackable_options
          model_class.history_trackable_options
        end

        def tracking_history_enabled?
          expects "#{model_class} to be tracked history"
          model_class.respond_to?(:tracking_enabled?) && model_class.tracking_enabled?
        end

        def parent_options?
          if @options[:parent]
            expects "tracked history parent (:#{history_trackable_options[:parent]}) to match (:#{@options[:parent]})"
            history_trackable_options[:parent] == @options[:parent]
          else
            true
          end
        end

        def inverse_of_options?
          if @options[:inverse_of]
            expects "tracked history inverse_of (:#{history_trackable_options[:inverse_of]}) to match (:#{@options[:inverse_of]})"
            history_trackable_options[:inverse_of] == @options[:inverse_of]
          else
            true
          end
        end

        def only_options?
          if @options[:only]
            only = @options[:only].map { |field| model_class.database_field_name(field) }
            expects "tracked history fields (#{model_class.tracked_fields.inspect}) to match (#{only})"
            model_class.tracked_fields.sort == only.sort
          else
            true
          end
        end

        def except_options?
          if @options[:except]
            except = @options[:except].map { |field| model_class.database_field_name(field) }
            expects "non tracked history fields (#{model_class.non_tracked_fields.inspect}) to match (#{except})"
            (model_class.non_tracked_fields & except).present?
          else
            true
          end
        end

        def on_options?
          if @options[:on]
            expects "tracked history callbacks (#{history_trackable_options[:on].inspect}) to match (#{@options[:on]})"
            history_trackable_options[:on].sort == @options[:on].sort
          else
            true
          end
        end

        def changes_method_options?
          if @options[:changes_method]
            expects "tracked history callbacks (#{history_trackable_options[:changes_method].inspect}) to match (#{@options[:changes_method]})"
            history_trackable_options[:changes_method] == @options[:changes_method]
          else
            true
          end
        end

        def class_name_options?
          if @options[:class_name]
            expects "tracked history class_name (#{model_class.history_tracker_class.name}) to match (#{@options[:class_name]})"
            model_class.history_tracker_class.name == @options[:class_name]
          else
            true
          end
        end
    end
  end
end

require 'rspec/core'
RSpec.configure do |config|
  config.include HistoryTracker::Matchers
end