require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]

SimpleCov.start do
  add_filter '/spec/'
end

require 'pry'
require 'mongoid-rspec'
require 'history_tracker'
require 'history_tracker/matchers'

# active_record
load File.dirname(__FILE__) + '/support/active_record/schema.rb'
load File.dirname(__FILE__) + '/support/active_record/models.rb'

# mongoid
load File.dirname(__FILE__) + '/support/mongoid/connection.rb'
load File.dirname(__FILE__) + '/support/mongoid/models.rb'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.include Mongoid::Matchers, type: :mongoid

  # Clean/Reset Mongoid DB prior to running the tests
  config.before :each do
    Mongoid.default_session.drop
  end
end

current_user = User.create!(email: 'chamnap@yoolk.com')
# HistoryTracker.current_modifier = current_user

# Hash#diff is depreciated in rails 4
def diff(h1,h2)
  h1.dup.delete_if { |k, v|
    h2[k] == v
  }.merge!(h2.dup.delete_if { |k, v| h1.has_key?(k) })
end

require 'rspec/expectations'

# be_eql_hash
RSpec::Matchers.define :be_eql_hash do |expected|
  match do |actual|
    expected = expected.stringify_keys.dup
    if expected.keys.length != actual.keys.length
      false
    else
      diff = diff(expected, actual)
      if diff.blank?
        true
      else
        # http://railsware.com/blog/2014/04/01/time-comparison-in-ruby/
        result = diff.collect do |k, v|
          Time.at(actual[k].to_i) == Time.at(expected[k].to_i)
        end
        result.all? { |item| item == true }
      end
    end
  end
end