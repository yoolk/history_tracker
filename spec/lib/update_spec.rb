require 'spec_helper'

describe 'Tracking changes when update' do
  context "when enabled" do
    it 'should record changes when update' do
      listing = Listing.create!(name: 'MongoDB 102', view_count: 102)
      expect {
        listing.update_attributes!(name: 'MongoDB 201', view_count: 103)
      }.to change { Listing.history_class.count }.by(1)
    end

    it 'should retrieve changes history' do
      listing = Listing.create!(name: 'MongoDB 102', view_count: 102)
      listing.update_attributes!(name: 'MongoDB 201', view_count: 103)

      tracked = listing.history_tracks.last
      tracked.should be_present
      tracked.original.should == {"name"=>"MongoDB 102", "view_count"=>102}
      tracked.modified.should == {"name"=>"MongoDB 201", "view_count"=>103}
      tracked.changeset.should == {"name"=>["MongoDB 102", "MongoDB 201"], "view_count"=>[102, 103]}
      tracked.action.should   == "update"
      tracked.scope.should    == "listing"
    end

    it 'should track changes with :class_name' do
      listing = ListingClassName.create!(name: 'MongoDB 101', view_count: 101)

      expect {
        listing.update_attributes!(name: 'MongoDB 102', view_count: 102)
      }.to change { ListingHistory.count }.by(1)
    end

    it 'should track changes with :only options' do
      listing = ListingOnly.create!(name: 'MongoDB 101', view_count: 101)
      listing.update_attributes!(name: 'MongoDB 102', view_count: 102)

      listing.history_tracks.last.original.should == {"name"=>"MongoDB 101"}
      listing.history_tracks.last.modified.should == {"name"=>"MongoDB 102"}
      listing.history_tracks.last.changeset.should == {"name"=>["MongoDB 101", "MongoDB 102"]}
    end

    it 'should track changes with :except options' do
      listing = ListingExcept.create!(name: 'MongoDB 101', view_count: 101)
      listing.update_attributes!(name: 'MongoDB 102', view_count: 102)

      listing.history_tracks.last.original.should == {"view_count"=>101}
      listing.history_tracks.last.modified.should == {"view_count"=>102}
      listing.history_tracks.last.changeset.should == {"view_count"=>[101, 102]}
    end

    it 'should not track changes with :except, all columns' do
      listing = ListingExceptAll.create!(name: 'MongoDB 101', view_count: 101)

      expect {
        listing.update_attributes!(name: 'MongoDB 102', view_count: 102)
      }.to change { ListingExceptAll.history_class.count }.by(0)
    end

    it 'should track changes with on: [:update]' do
      listing = ListingOnUpdate.new(name: 'MongoDB 101', description: 'Open source document database', is_active: true, view_count: 5)

      expect { listing.save }.to_not change { ListingOnUpdate.history_class.count }.by(1)
      expect { listing.update_attributes!(name: 'MongoDB 102') }.to change { ListingOnUpdate.history_class.count }
      expect { listing.destroy }.to_not change { ListingOnUpdate.history_class.count }
    end
  end

  context "when disabled" do
    before(:each) do
      @listing = Listing.create!(name: 'MongoDB 101', view_count: 101)
    end

    after(:each) do
      Listing.enable_tracking
    end
    
    it "should not track changes" do
      Listing.disable_tracking

      expect {
        @listing.update_attributes!(name: 'MongoDB 102', view_count: 102)
      }.to change { Listing.history_class.count }.by(0)
    end

    it "should not track #without_tracking without :save" do
      @listing.name = 'MongoDB 102'
      expect { @listing.without_tracking { @listing.save } }.to change { Listing.history_class.count }.by(0)
    end

    it "should not track #without_tracking with :save" do
      @listing.name = 'MongoDB 102'
      expect { @listing.without_tracking(:save) }.to change { Listing.history_class.count }.by(0)
    end
  end
end