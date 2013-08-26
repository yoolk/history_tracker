require "spec_helper"

describe "Nested Association" do
  let!(:listing) { Listing.create!(name: 'MongoDB 101', view_count: 101) }
  let!(:album)   { listing.albums.create!(name: 'Profile 1') }
  let!(:image) { album.images.create!(caption: 'Product A') }

  context "scope" do
    it { expect(listing.history_tracks.count) == 1 }  
    it { expect(listing.history_tracks(scope: false).count) == 1 }  
    it { expect(listing.history_tracks(scope: true).count) == 3 }  
  end

  context "association" do
    it { expect(listing.history_tracks.count) == 1 }
    it { expect(listing.history_tracks[0].type) == 'Listing' }
    it { expect(listing.albums.history_tracks.count) == 1 }
    it { expect(listing.albums.history_tracks[0].type) == 'albums' }
    it { expect(listing.albums.first.images.history_tracks.count) == 1 }
    it { expect(listing.albums.first.images.history_tracks[0].type) == 'images' }
  end

  context "when created" do
    it "should record changes" do
      expect {
        album.images.create!(caption: 'Product A')
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from grand child" do
      image = album.images.create!(caption: 'Product A')

      tracked = image.history_tracks.last
      tracked.should be_present
      tracked.modifier.should == {"id"=>1, "email"=>"chamnap@yoolk.com"}
      tracked.association_chain.should == [{"id"=>listing.id, "name"=>"Listing"},{"id"=>album.id, "name"=>"albums"},{"id"=>image.id, "name"=>"images"}]
      tracked.original.should == {}
      tracked.modified.should == {"caption"=>"Product A", "album_id"=>album.id}
      tracked.action.should   == "create"
      tracked.scope.should    == "listing"
    end

    it "should retrieve changes from immediate child" do
      image = album.images.create!(caption: 'Product A')
      history_tracks = album.history_tracks(scope: true)
      expect(history_tracks.count) == 2
      expect(history_tracks[0].modified) == {"name"=>"Profile 1", "listing_id"=>listing.id}
      expect(history_tracks[1].modified) == {"caption"=>"Product A", "album_id"=>album.id}
    end

    it "should retrieve changes from parent" do
      image = album.images.create!(caption: 'Product A')

      history_tracks = listing.history_tracks(scope: true)
      expect(history_tracks.count) == 3
      expect(history_tracks[0].modified) == {"name"=>"MongoDB 101", "view_count"=>101}
      expect(history_tracks[1].modified) == {"name"=>"Profile 1", "listing_id"=>listing.id}
      expect(history_tracks[2].modified) == {"caption"=>"Product A", "album_id"=>album.id}
    end
  end

  context "when updated" do
    it "track changes when child record is updated" do
      expect {
        image.update_attributes!(caption: 'Product B')
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from grand child" do
      image.update_attributes!(caption: 'Product B')

      tracked = image.history_tracks.last
      tracked.should be_present
      tracked.association_chain.should == [{"id"=>listing.id, "name"=>"Listing"},{"id"=>album.id, "name"=>"albums"},{"id"=>image.id, "name"=>"images"}]
      tracked.original.should == {"id"=>image.id, "caption"=>"Product A", "album_id"=>album.id}
      tracked.modified.should == {"caption"=>"Product B"}
      tracked.changeset.should == {"caption"=>["Product A", "Product B"]}
      tracked.action.should   == "update"
      tracked.scope.should    == "listing"
    end

    it "should retrieve changes from immediate child" do
      image.update_attributes!(caption: 'Product B')

      history_tracks = album.history_tracks(scope: true)
      expect(history_tracks.count) == 3
      expect(history_tracks[0].modified) == {"name"=>"Profile 1", "listing_id"=>listing.id}
      expect(history_tracks[1].modified) == {"caption"=>"Product A", "album_id"=>album.id}
      expect(history_tracks[2].modified) == {"caption"=>"Product B"}
    end

    it "should retrieve changes from parent" do
      image.update_attributes!(caption: 'Product B')

      history_tracks = listing.history_tracks(scope: true)
      expect(history_tracks.count) == 4
      expect(history_tracks[0].modified) == {"name"=>"MongoDB 101", "view_count"=>101}
      expect(history_tracks[1].modified) == {"name"=>"Profile 1", "listing_id"=>listing.id}
      expect(history_tracks[2].modified) == {"caption"=>"Product A", "album_id"=>album.id}
      expect(history_tracks[3].modified) == {"caption"=>"Product B"}
    end
  end

  context "when destroy" do
    it "track changes when grand child record is destroyed" do
      expect {
        image.destroy
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from grand child" do
      image.destroy
      tracked = image.history_tracks.last
      tracked.should be_present
      tracked.association_chain.should == [{"id"=>listing.id, "name"=>"Listing"},{"id"=>album.id, "name"=>"albums"},{"id"=>image.id, "name"=>"images"}]
      tracked.original.should == {"id"=>image.id, "caption"=>"Product A", "album_id"=>album.id}
      tracked.modified.should == {}
      tracked.changeset.should == {}
      tracked.action.should   == "destroy"
      tracked.scope.should    == "listing"
    end

    it "should retrieve changes from immediate child" do
      image.destroy
      history_tracks = album.history_tracks(scope: true)
      expect(history_tracks.count) == 3
      expect(history_tracks[0].modified) == {"name"=>"Profile 1", "listing_id"=>listing.id}
      expect(history_tracks[1].modified) == {"caption"=>"Product A", "album_id"=>album.id}
      expect(history_tracks[2].modified) == {}
    end

    it "should retrieve changes from parent" do
      image.destroy
      history_tracks = listing.history_tracks(scope: true)
      expect(history_tracks.count) == 4
      expect(history_tracks[0].modified) == {"name"=>"MongoDB 101", "view_count"=>101}
      expect(history_tracks[1].modified) == {"name"=>"Profile 1", "listing_id"=>listing.id}
      expect(history_tracks[2].modified) == {"caption"=>"Product A", "album_id"=>album.id}
      expect(history_tracks[3].modified) == {}
    end
  end
end