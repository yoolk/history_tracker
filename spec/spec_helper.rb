require 'active_audit'
require 'pry'

# active_record
load File.dirname(__FILE__) + '/support/active_record/schema.rb'
load File.dirname(__FILE__) + '/support/active_record/models.rb'

# mongoid
load File.dirname(__FILE__) + '/support/mongoid/connection.rb'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Clean/Reset Mongoid DB prior to running the tests
  config.before :each do
    Mongoid.default_session.drop
  end
end

def current_user
  OpenStruct.new(id: 1)
end