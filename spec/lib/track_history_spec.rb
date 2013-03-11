require 'spec_helper'

describe 'Track History' do
  context 'setup' do
    it 'should return true for tracked class' do
      Book.track?.should be_true
    end

    it 'should return false for non-tracked class' do
      class NonTrackedBook < ActiveRecord::Base; end
      
      NonTrackedBook.track?.should be_false
    end
  end

  context 'Disable/Enable flag per model' do
    after(:each) do
      Book.enable_tracking
    end

    it 'should enable tracking by default' do
      Book.track_history?.should be_true
    end

    it 'should disable tracking' do
      Book.disable_tracking
      Book.track_history?.should be_false
    end

    it 'should enable tracking' do
      Book.disable_tracking
      Book.track_history?.should be_false

      Book.enable_tracking
      Book.track_history?.should be_true
    end

    it 'should disable tracking with block' do
      expect {
        Book.without_tracking { Book.create(name: 'MongoDB 101') }
      }.to change { Book.history_class.count }.by(0)
      Book.track_history?.should be_true
    end
  end

  context "Enable/Disable globally" do
    after(:each) do
      HistoryTracker.enabled = true
      Book.enable_tracking
    end

    it 'should enable by default' do
      HistoryTracker.enabled?.should be_true
    end

    it 'should disable tracking' do
      HistoryTracker.enabled = false

      HistoryTracker.enabled?.should be_false
      Book.track_history?.should be_false
    end

    it 'should follow global setting' do
      HistoryTracker.enabled = false
      Book.enable_tracking
      HistoryTracker.enabled?.should be_false
      Book.track_history?.should be_false

      HistoryTracker.enabled = true
      Book.disable_tracking
      HistoryTracker.enabled?.should be_true
      Book.track_history?.should be_false

      HistoryTracker.enabled = true
      Book.enable_tracking
      HistoryTracker.enabled?.should be_true
      Book.track_history?.should be_true
    end
  end
end