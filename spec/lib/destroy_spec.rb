require 'spec_helper'

describe 'Tracking changes when destroy' do
  context "when enabled" do
    it 'should record changes when destroy' do
      listing = Listing.create!(name: 'MongoDB 102', view_count: 102)
      expect {
        listing.destroy
      }.to change { Listing.history_class.count }.by(1)
    end

    it 'should retrieve changes history' do
      listing = Listing.create!(name: 'MongoDB 102', view_count: 102)
      listing.destroy

      tracked = listing.history_tracks.last
      tracked.should be_present
      tracked.modifier.should == {"id"=>1, "email"=>"chamnap@yoolk.com"}
      tracked.original.should be_equal({"id"=>listing.id, "name"=>"MongoDB 102", "description"=>nil, "is_active"=>nil, "view_count"=>102, "created_at"=>listing.created_at.utc, "updated_at"=>listing.updated_at.utc, "location_id"=>nil})
      tracked.modified.should == {}
      tracked.changeset.should == {}
      tracked.action.should   == "destroy"
      tracked.scope.should    == "listing"
    end

    it 'should track changes with :class_name' do
      listing = ListingClassName.create!(name: 'MongoDB 101', view_count: 101)

      expect {
        listing.destroy
      }.to change { ListingHistory.count }.by(1)
    end

    it 'should track changes with :only options' do
      listing = ListingOnly.create!(name: 'MongoDB 101', view_count: 101)
      listing.destroy

      listing.history_tracks.last.modified.should == {}
      listing.history_tracks.last.original.should be_equal({"id"=>listing.id, "name"=>"MongoDB 101", "created_at"=>listing.created_at.utc, "updated_at"=>listing.updated_at.utc})
    end

    it 'should track changes with :except options' do
      listing = ListingExcept.create!(name: 'MongoDB 101', view_count: 101)
      listing.destroy

      listing.history_tracks.last.original.should be_equal({"id"=>listing.id, "description"=>nil, "is_active"=>nil, "view_count"=>101, "created_at"=>listing.created_at.utc, "updated_at"=>listing.updated_at.utc, "location_id"=>nil})
      listing.history_tracks.last.modified.should == {}
    end

    it 'should track change with on: [:destroy]' do
      listing = ListingOnDestroy.new(name: 'MongoDB 101', description: 'Open source document database', is_active: true, view_count: 5)

      expect { listing.save }.to_not change { ListingOnDestroy.history_class.count }.by(1)
      expect { listing.update_attributes!(name: 'MongoDB 102') }.to_not change { ListingOnDestroy.history_class.count }
      expect { listing.destroy }.to change { ListingOnDestroy.history_class.count }
    end
  end

  context "when disabled" do
    before(:each) do
      @listing = Listing.create!(name: 'MongoDB 101', view_count: 101)
    end

    after(:each) do
      Listing.enable_tracking
    end
    
    it "should not track" do
      Listing.disable_tracking

      expect { @listing.destroy }.to change { Listing.history_class.count }.by(0)
    end

    it "should not track #without_tracking without :destroy" do
      expect { @listing.without_tracking { @listing.destroy } }.to change { Listing.history_class.count }.by(0)
    end

    it "should not track #without_tracking with :destroy" do
      expect { @listing.without_tracking(:destroy) }.to change { Listing.history_class.count }.by(0)
    end
  end
end