require 'spec_helper'

describe HistoryTracker do
  it '#trackable_class_options' do
    class Listing1 < ActiveRecord::Base
      self.table_name = 'listings'

      track_history
    end

    expect(HistoryTracker.trackable_class_options.keys).to include('Listing1')
  end
end