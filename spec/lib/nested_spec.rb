require "spec_helper"

describe "Nested Association" do
  before(:each) do
    @listing = Listing.create!(name: 'MongoDB 101', view_count: 101)
    @album   = @listing.albums.create!(name: 'Profile 1')
  end

  context "when created" do
    it "should record changes" do
      expect {
        @album.images.create!(caption: 'Product A')
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from grand child" do
      image = @album.images.create!(caption: 'Product A')

      tracked = image.history_tracks.last
      tracked.should be_present
      tracked.association_chain.should == [{"id"=>@listing.id, "name"=>"Listing"},{"id"=>@album.id, "name"=>"albums"},{"id"=>image.id, "name"=>"images"}]
      tracked.original.should == {}
      tracked.modified.should == {"caption"=>"Product A", "album_id"=>@album.id}
      tracked.action.should   == "create"
      tracked.scope.should    == "listing"
    end

    it "should retrieve changes from immediate child" do
      image = @album.images.create!(caption: 'Product A')

      @album.history_tracks.count.should == 2
      @album.history_tracks[0].modified.should == {"name"=>"Profile 1", "listing_id"=>@listing.id}
      @album.history_tracks[1].modified.should == {"caption"=>"Product A", "album_id"=>@album.id}
    end

    it "should retrieve changes from parent" do
      image = @album.images.create!(caption: 'Product A')

      @listing.history_tracks.count.should == 3
      @listing.history_tracks[0].modified.should == {"name"=>"MongoDB 101", "view_count"=>101}
      @listing.history_tracks[1].modified.should == {"name"=>"Profile 1", "listing_id"=>@listing.id}
      @listing.history_tracks[2].modified.should == {"caption"=>"Product A", "album_id"=>@album.id}
    end
  end

  context "when updated" do
    before(:each) do
      @image = @album.images.create!(caption: 'Product A')
    end

    it "track changes when child record is updated" do
      expect {
        @image.update_attributes!(caption: 'Product B')
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from grand child" do
      @image.update_attributes!(caption: 'Product B')

      tracked = @image.history_tracks.last
      tracked.should be_present
      tracked.association_chain.should == [{"id"=>@listing.id, "name"=>"Listing"},{"id"=>@album.id, "name"=>"albums"},{"id"=>@image.id, "name"=>"images"}]
      tracked.original.should == {"caption"=>"Product A"}
      tracked.modified.should == {"caption"=>"Product B"}
      tracked.changeset.should == {"caption"=>["Product A", "Product B"]}
      tracked.action.should   == "update"
      tracked.scope.should    == "listing"
    end

    it "should retrieve changes from immediate child" do
      @image.update_attributes!(caption: 'Product B')

      @album.history_tracks.count.should == 3
      @album.history_tracks[0].modified.should == {"name"=>"Profile 1", "listing_id"=>@listing.id}
      @album.history_tracks[1].modified.should == {"caption"=>"Product A", "album_id"=>@album.id}
      @album.history_tracks[2].modified.should == {"caption"=>"Product B"}
    end

    it "should retrieve changes from parent" do
      @image.update_attributes!(caption: 'Product B')

      @listing.history_tracks.count.should == 4
      @listing.history_tracks[0].modified.should == {"name"=>"MongoDB 101", "view_count"=>101}
      @listing.history_tracks[1].modified.should == {"name"=>"Profile 1", "listing_id"=>@listing.id}
      @listing.history_tracks[2].modified.should == {"caption"=>"Product A", "album_id"=>@album.id}
      @listing.history_tracks[3].modified.should == {"caption"=>"Product B"}
    end
  end

  context "when destroy" do
    before(:each) do
      @image = @album.images.create!(caption: 'Product A')
    end

    it "track changes when grand child record is destroyed" do
      expect {
        @image.destroy
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from grand child" do
      @image.destroy

      tracked = @image.history_tracks.last
      tracked.should be_present
      tracked.association_chain.should == [{"id"=>@listing.id, "name"=>"Listing"},{"id"=>@album.id, "name"=>"albums"},{"id"=>@image.id, "name"=>"images"}]
      tracked.original.should == {"id"=>@image.id, "caption"=>"Product A", "album_id"=>@album.id}
      tracked.modified.should == {}
      tracked.changeset.should == {}
      tracked.action.should   == "destroy"
      tracked.scope.should    == "listing"
    end

    it "should retrieve changes from immediate child" do
      @image.destroy

      @album.history_tracks.count.should == 3
      @album.history_tracks[0].modified.should == {"name"=>"Profile 1", "listing_id"=>@listing.id}
      @album.history_tracks[1].modified.should == {"caption"=>"Product A", "album_id"=>@album.id}
      @album.history_tracks[2].modified.should == {}
    end

    it "should retrieve changes from parent" do
      @image.destroy

      @listing.history_tracks.count.should == 4
      @listing.history_tracks[0].modified.should == {"name"=>"MongoDB 101", "view_count"=>101}
      @listing.history_tracks[1].modified.should == {"name"=>"Profile 1", "listing_id"=>@listing.id}
      @listing.history_tracks[2].modified.should == {"caption"=>"Product A", "album_id"=>@album.id}
      @listing.history_tracks[3].modified.should == {}
    end
  end
end