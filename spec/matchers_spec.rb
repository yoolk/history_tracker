require 'spec_helper'

describe Listing do
  it { should be_tracked_history }
  it { should be_tracked_history.except(:view_count) }
  it { should be_tracked_history.only(:name, :description, :is_active, :location_id) }
  it { should be_tracked_history.changes_method(:history_changes) }
end

describe Album do
  it { should be_tracked_history }
  it { should be_tracked_history.only(:name) }
  it { should be_tracked_history.parent(:listing) }
  it { should be_tracked_history.inverse_of(:albums) }
  it { should be_tracked_history.on(:create, :update, :destroy) }
  it { should be_tracked_history.class_name('ListingHistoryTracker') }
end

describe Photo do
  it { should be_tracked_history.class_name('ListingHistoryTracker') }
end