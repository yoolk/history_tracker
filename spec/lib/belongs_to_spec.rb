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
      tracked.modified.should == {"name"=>"MongoDB Listing", "description"=>"Document Database", "is_active"=>true, "view_count"=>101, "location_id"=>@location1.id, "location_name"=>@location1.name, "location_priority"=>@location1.priority}
      tracked.changeset.should == {"name"=>[nil, "MongoDB Listing"], "description"=>[nil, "Document Database"], "is_active"=>[nil, true], "view_count"=>[nil, 101], "location_id"=>[nil, @location1.id], "location_name"=>[nil, @location1.name], "location_priority"=>[nil, @location1.priority]}
      tracked.action.should   == "create"
      tracked.scope.should    == "listing_include"
    end

    it "should retrieve changes with selected fields" do
      listing = ListingIncludeFields.create!(name: 'MongoDB Listing', description: 'Document Database', view_count: 101, is_active: true, location: @location1)

      tracked = listing.history_tracks.last
      tracked.should be_present
      tracked.original.should == {}
      tracked.modified.should == {"name"=>"MongoDB Listing", "description"=>"Document Database", "is_active"=>true, "view_count"=>101, "location_id"=>@location1.id, "location_name"=>@location1.name}
      tracked.changeset.should == {"name"=>[nil, "MongoDB Listing"], "description"=>[nil, "Document Database"], "is_active"=>[nil, true], "view_count"=>[nil, 101], "location_id"=>[nil, @location1.id], "location_name"=>[nil, @location1.name]}
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
      @listing.update_attributes(name: 'MongoDB Listing 1')

      @listing.history_tracks.last.modified.should == {"name"=>"MongoDB Listing 1"}
    end

    it "should retrieve changes" do
      @listing.update_attributes(name: 'MongoDB Listing 1', location: @location2)

      tracked = @listing.history_tracks.last
      tracked.should be_present
      tracked.association_chain.should == [{"id"=>@listing.id, "name"=>"ListingInclude"}]
      tracked.original.should be_equal({"id"=>@listing.id, "name"=>"MongoDB Listing", "description"=>"Document Database", "is_active"=>true, "view_count"=>101, "location_id"=>@location1.id, "location_name"=>@location1.name, "location_priority"=>@location1.priority, "created_at"=>@listing.created_at.utc, "updated_at"=>@listing.updated_at.utc})
      tracked.modified.should == {"name"=>"MongoDB Listing 1", "location_id"=>@location2.id, "location_name"=>@location2.name, "location_priority"=>@location2.priority}
      tracked.changeset.should == {"name"=>["MongoDB Listing", "MongoDB Listing 1"], "location_id"=>[@location1.id, @location2.id], "location_name"=>[@location1.name, @location2.name], "location_priority"=>[@location1.priority, @location2.priority]}
      tracked.action.should   == "update"
      tracked.scope.should    == "listing_include"
    end

    it "should retrieve changes with selected fields" do
      @listing = ListingIncludeFields.create!(name: 'MongoDB Listing', description: 'Document Database', view_count: 101, is_active: true, location: @location1)
      @listing.update_attributes(name: 'MongoDB Listing 1', location: @location2)

      tracked = @listing.history_tracks.last
      tracked.should be_present
      tracked.original.should be_equal({"id"=>@listing.id, "name"=>"MongoDB Listing", "description"=>"Document Database", "is_active"=>true, "view_count"=>101, "location_id"=>@location1.id, "location_name"=>@location1.name, "created_at"=>@listing.created_at.utc, "updated_at"=>@listing.updated_at.utc})
      tracked.modified.should == {"name"=>"MongoDB Listing 1", "location_id"=>@location2.id, "location_name"=>@location2.name}
      tracked.changeset.should == {"name"=>["MongoDB Listing", "MongoDB Listing 1"], "location_id"=>[@location1.id, @location2.id], "location_name"=>[@location1.name, @location2.name]}
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
      tracked.original.should be_equal({"id"=>@listing.id, "name"=>"MongoDB Listing", "description"=>"Document Database", "is_active"=>true, "view_count"=>101, "location_id"=>@location1.id, "location_name"=>@location1.name, "location_priority"=>@location1.priority, "created_at"=>@listing.created_at.utc, "updated_at"=>@listing.updated_at.utc})
      tracked.modified.should == {}
      tracked.changeset.should == {}
      tracked.action.should   == "destroy"
      tracked.scope.should    == "listing_include"
    end

    it "should retrieve changes" do
      @listing = ListingIncludeFields.create!(name: 'MongoDB Listing', description: 'Document Database', view_count: 101, is_active: true, location: @location1)
      @listing.destroy

      tracked = @listing.history_tracks.last
      tracked.should be_present
      tracked.original.should be_equal({"id"=>@listing.id, "name"=>"MongoDB Listing", "description"=>"Document Database", "is_active"=>true, "view_count"=>101, "location_id"=>@location1.id, "location_name"=>@location1.name, "created_at"=>@listing.created_at.utc, "updated_at"=>@listing.updated_at.utc})
      tracked.modified.should == {}
      tracked.changeset.should == {}
    end
  end
end