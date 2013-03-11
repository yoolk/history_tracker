require 'spec_helper'

describe 'Track History' do
  context 'setup' do
    it 'should return true for tracked class' do
      Listing.track?.should be_true
    end

    it 'should return false for non-tracked class' do
      class NonTrackedListing < ActiveRecord::Base; end
      
      NonTrackedListing.track?.should be_false
    end
  end

  context 'Disable/Enable flag per model' do
    after(:each) do
      Listing.enable_tracking
    end

    it 'should enable tracking by default' do
      Listing.track_history?.should be_true
    end

    it 'should disable tracking' do
      Listing.disable_tracking
      Listing.track_history?.should be_false
    end

    it 'should enable tracking' do
      Listing.disable_tracking
      Listing.track_history?.should be_false

      Listing.enable_tracking
      Listing.track_history?.should be_true
    end

    it 'should disable tracking with block' do
      expect {
        Listing.without_tracking { Listing.create(name: 'MongoDB 101') }
      }.to change { Listing.history_class.count }.by(0)
      Listing.track_history?.should be_true
    end
  end

  context "Enable/Disable globally" do
    after(:each) do
      HistoryTracker.enabled = true
      Listing.enable_tracking
    end

    it 'should enable by default' do
      HistoryTracker.enabled?.should be_true
    end

    it 'should disable tracking' do
      HistoryTracker.enabled = false

      HistoryTracker.enabled?.should be_false
      Listing.track_history?.should be_false
    end

    it 'should follow global setting' do
      HistoryTracker.enabled = false
      Listing.enable_tracking
      HistoryTracker.enabled?.should be_false
      Listing.track_history?.should be_false

      HistoryTracker.enabled = true
      Listing.disable_tracking
      HistoryTracker.enabled?.should be_true
      Listing.track_history?.should be_false

      HistoryTracker.enabled = true
      Listing.enable_tracking
      HistoryTracker.enabled?.should be_true
      Listing.track_history?.should be_true
    end
  end
end