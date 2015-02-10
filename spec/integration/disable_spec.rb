require 'spec_helper'

describe 'Disable tracking' do
  context "on create" do
    let(:listing) { Listing.new(name: 'Listing 1', description: 'Description 1') }

    it "should not write track" do
      expect {
        Listing.disable_tracking
        listing.save!
        Listing.enable_tracking
      }.to change { Listing.history_tracker_class.count }.by(0)
    end

    it "#without_tracking" do
      expect { listing.without_tracking { listing.save! } }.to change { Listing.history_tracker_class.count }.by(0)
    end

    it "#without_tracking with method :save" do
      expect { listing.without_tracking(:save) }.to change { Listing.history_tracker_class.count }.by(0)
    end
  end

  context "on update" do
    let!(:listing) { Listing.create!(name: 'Listing 1', description: 'Description 1') }

    it "should not write track" do
      expect {
        Listing.disable_tracking
        listing.update_attributes!(name: 'Listing 2')
        Listing.enable_tracking
      }.to change { Listing.history_tracker_class.count }.by(0)
    end

    it "#without_tracking" do
      expect { listing.without_tracking { listing.update_attributes!(name: 'Listing 2') } }.to change { Listing.history_tracker_class.count }.by(0)
    end

    it "#without_tracking with method :save" do
      listing.assign_attributes(name: 'Listing 2')
      expect { listing.without_tracking(:save!) }.to change { Listing.history_tracker_class.count }.by(0)
    end
  end

  context "on destroy" do
    let!(:listing) { Listing.create!(name: 'Listing 1', description: 'Description 1') }

    it "should not write track" do
      expect {
        Listing.disable_tracking
        listing.destroy
        Listing.enable_tracking
      }.to change { Listing.history_tracker_class.count }.by(0)
    end

    it "#without_tracking" do
      expect { listing.without_tracking { listing.destroy } }.to change { Listing.history_tracker_class.count }.by(0)
    end

    it "#without_tracking with method :save" do
      expect { listing.without_tracking(:destroy) }.to change { Listing.history_tracker_class.count }.by(0)
    end
  end
end