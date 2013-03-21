require 'spec_helper'

describe "Belongs To Association" do
  before(:all) do
    @location1 = Location.create!(name: 'Phnom Penh', priority: 1)
    @location2 = Location.create!(name: 'Siem Reap', priority: 2)
  end

  after(:all) do
    Location.delete_all
  end

  context "when created" do
    it "should record when changes :belongs_to" do
      expect {
        listing = ListingInclude.create!(name: 'MongoDB Listing', description: 'Document Database', view_count: 101, is_active: true, location: @location1)
      }.to change { ListingInclude.history_class.count }.by(1)
    end

    it "should retrieve changes" do
      listing = ListingInclude.create!(name: 'MongoDB Listing', description: 'Document Database', view_count: 101, is_active: true, location: @location1)

      tracked = listing.history_tracks.last
      tracked.should be_present
      tracked.association_chain.should == [{"id"=>listing.id, "name"=>"ListingInclude"}]
      tracked.original.should == {}
      tracked.modified.should == {"name"=>"MongoDB Listing", "description"=>"Document Database", "is_active"=>true, "view_count"=>101, "location"=>{"id"=>@location1.id, "name"=>@location1.name, "priority"=>@location1.priority}}
      tracked.changeset.should == {"name"=>[nil, "MongoDB Listing"], "description"=>[nil, "Document Database"], "is_active"=>[nil, true], "view_count"=>[nil, 101], "location"=>[nil, {"id"=>@location1.id, "name"=>@location1.name, "priority"=>@location1.priority}]}
      tracked.action.should   == "create"
      tracked.scope.should    == "listing_include"
    end
  end

  context "when updated" do
    before(:each) do
      @listing = ListingInclude.create!(name: 'MongoDB Listing', description: 'Document Database', view_count: 101, is_active: true, location: @location1)
    end
    
    it "should record changes" do
      expect {
        @listing.update_attributes(name: 'MongoDB Listing 1', location: @location2)
      }.to change { ListingInclude.history_class.count }.by(1)
    end

    it "should record changes when doesn't changes :belongs_to" do
      expect {
        @listing.update_attributes(name: 'MongoDB Listing 1')
      }.to change { ListingInclude.history_class.count }.by(1)
    end

    it "should retrieve changes" do
      @listing.update_attributes(name: 'MongoDB Listing 1', location: @location2)

      tracked = @listing.history_tracks.last
      tracked.should be_present
      tracked.association_chain.should == [{"id"=>@listing.id, "name"=>"ListingInclude"}]
      tracked.original.should include({"id"=>@listing.id, "name"=>"MongoDB Listing", "description"=>"Document Database", "is_active"=>true, "view_count"=>101, "location_id"=>@location1.id, "location"=>{"id"=>@location1.id, "name"=>@location1.name, "priority"=>@location1.priority}})
      tracked.modified.should == {"name"=>"MongoDB Listing 1", "location"=>{"id"=>@location2.id, "name"=>@location2.name, "priority"=>@location2.priority}}
      tracked.changeset.should == {"name"=>["MongoDB Listing", "MongoDB Listing 1"], "location"=>[{"id"=>@location1.id, "name"=>@location1.name, "priority"=>@location1.priority}, {"id"=>@location2.id, "name"=>@location2.name, "priority"=>@location2.priority}]}
      tracked.action.should   == "update"
      tracked.scope.should    == "listing_include"
    end
  end

  context "when destroyed" do
    before(:each) do
      @listing = ListingInclude.create!(name: 'MongoDB Listing', description: 'Document Database', view_count: 101, is_active: true, location: @location1)
    end

    it "should record changes" do
      expect {
        @listing.destroy
      }.to change { ListingInclude.history_class.count }.by(1)
    end

    it "should retrieve changes" do
      @listing.destroy

      tracked = @listing.history_tracks.last
      tracked.should be_present
      tracked.association_chain.should == [{"id"=>@listing.id, "name"=>"ListingInclude"}]
      tracked.original.should include({"id"=>@listing.id, "name"=>"MongoDB Listing", "description"=>"Document Database", "is_active"=>true, "view_count"=>101, "location_id"=>@location1.id, "location"=>{"id"=>@location1.id, "name"=>@location1.name, "priority"=>@location1.priority}})
      tracked.modified.should == {}
      tracked.changeset.should == {}
      tracked.action.should   == "destroy"
      tracked.scope.should    == "listing_include"
    end
  end
end