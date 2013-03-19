require 'history_tracker'
require 'pry'

# active_record
load File.dirname(__FILE__) + '/support/active_record/schema.rb'
load File.dirname(__FILE__) + '/support/active_record/models.rb'

# mongoid
load File.dirname(__FILE__) + '/support/mongoid/connection.rb'
load File.dirname(__FILE__) + '/support/mongoid/models.rb'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Clean/Reset Mongoid DB prior to running the tests
  config.before :each do
    Mongoid.default_session.drop
  end
end

# Stub current user
User.create!(id: 1, email: 'chamnap@yoolk.com')
def current_user
  User.find(1)
end
HistoryTracker.current_modifier = current_user