require "spec_helper"

describe "Nested Association" do
  let!(:listing) { Listing.create!(name: 'MongoDB 101', view_count: 101) }
  let!(:album)   { listing.albums.create!(name: 'Profile 1') }
  let!(:image) { album.images.create!(caption: 'Product A') }

  context "scope" do
    it { expect(listing.history_tracks.count).to eq(1) }  
    it { expect(listing.history_tracks(scope: false).count).to eq(1) }  
    it { expect(listing.history_tracks(scope: true).count).to eq(3) }  
  end

  context "association" do
    it { expect(listing.history_tracks.count).to eq(1) }
    it { expect(listing.history_tracks[0].type).to eq('Listing') }
    it { expect(listing.albums.history_tracks.count).to eq(1) }
    it { expect(listing.albums.history_tracks[0].type).to eq('albums') }
    it { expect(listing.albums.first.images.history_tracks.count).to eq(1) }
    it { expect(listing.albums.first.images.history_tracks[0].type).to eq('images') }
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
      expect(tracked).to be_present
      expect(tracked.modifier).to eq({"id"=>1, "email"=>"chamnap@yoolk.com"})
      expect(tracked.association_chain).to eq([{"id"=>listing.id, "name"=>"Listing"},{"id"=>album.id, "name"=>"albums"},{"id"=>image.id, "name"=>"images"}])
      expect(tracked.original).to eq({})
      expect(tracked.modified).to eq({"caption"=>"Product A", "album_id"=>album.id})
      expect(tracked.action).to eq("create")
      expect(tracked.scope).to eq("listing")
      expect(tracked.type).to eq("images")
    end

    it "should retrieve changes from immediate child" do
      history_tracks = album.history_tracks(scope: true)
      expect(history_tracks.count).to eq(2)
      expect(history_tracks[0].modified).to eq({"name"=>"Profile 1", "listing_id"=>listing.id})
      expect(history_tracks[1].modified).to eq({"caption"=>"Product A", "album_id"=>album.id})
    end

    it "should retrieve changes from parent" do
      history_tracks = listing.history_tracks(scope: true)
      expect(history_tracks.count).to eq(3)
      expect(history_tracks[0].modified).to eq({"name"=>"MongoDB 101", "view_count"=>101})
      expect(history_tracks[1].modified).to eq({"name"=>"Profile 1", "listing_id"=>listing.id})
      expect(history_tracks[2].modified).to eq({"caption"=>"Product A", "album_id"=>album.id})
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
      expect(tracked).to be_present
      expect(tracked.association_chain).to eq([{"id"=>listing.id, "name"=>"Listing"},{"id"=>album.id, "name"=>"albums"},{"id"=>image.id, "name"=>"images"}])
      expect(tracked.original).to eq({"id"=>image.id, "caption"=>"Product A", "album_id"=>album.id})
      expect(tracked.modified).to eq({"caption"=>"Product B"})
      expect(tracked.changeset).to eq({"caption"=>["Product A", "Product B"]})
      expect(tracked.action).to eq("update")
      expect(tracked.scope).to eq("listing")
      expect(tracked.type).to eq("images")
    end

    it "should retrieve changes from immediate child" do
      image.update_attributes!(caption: 'Product B')

      history_tracks = album.history_tracks(scope: true)
      expect(history_tracks.count) == 3
      expect(history_tracks[0].modified).to eq({"name"=>"Profile 1", "listing_id"=>listing.id})
      expect(history_tracks[1].modified).to eq({"caption"=>"Product A", "album_id"=>album.id})
      expect(history_tracks[2].modified).to eq({"caption"=>"Product B"})
    end

    it "should retrieve changes from parent" do
      image.update_attributes!(caption: 'Product B')

      history_tracks = listing.history_tracks(scope: true)
      expect(history_tracks.count).to eq(4)
      expect(history_tracks[0].modified).to eq({"name"=>"MongoDB 101", "view_count"=>101})
      expect(history_tracks[1].modified).to eq({"name"=>"Profile 1", "listing_id"=>listing.id})
      expect(history_tracks[2].modified).to eq({"caption"=>"Product A", "album_id"=>album.id})
      expect(history_tracks[3].modified).to eq({"caption"=>"Product B"})
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
      expect(tracked).to be_present
      expect(tracked.association_chain).to eq([{"id"=>listing.id, "name"=>"Listing"},{"id"=>album.id, "name"=>"albums"},{"id"=>image.id, "name"=>"images"}])
      expect(tracked.original).to eq({"id"=>image.id, "caption"=>"Product A", "album_id"=>album.id})
      expect(tracked.modified).to eq({})
      expect(tracked.changeset).to eq({})
      expect(tracked.action).to eq("destroy")
      expect(tracked.scope).to eq("listing")
      expect(tracked.type).to eq("images")
    end

    it "should retrieve changes from immediate child" do
      image.destroy
      history_tracks = album.history_tracks(scope: true)
      expect(history_tracks.count).to eq(3)
      expect(history_tracks[0].modified).to eq({"name"=>"Profile 1", "listing_id"=>listing.id})
      expect(history_tracks[1].modified).to eq({"caption"=>"Product A", "album_id"=>album.id})
      expect(history_tracks[2].modified).to eq({})
    end

    it "should retrieve changes from parent" do
      image.destroy
      history_tracks = listing.history_tracks(scope: true)
      expect(history_tracks.count).to eq(4)
      expect(history_tracks[0].modified).to eq({"name"=>"MongoDB 101", "view_count"=>101})
      expect(history_tracks[1].modified).to eq({"name"=>"Profile 1", "listing_id"=>listing.id})
      expect(history_tracks[2].modified).to eq({"caption"=>"Product A", "album_id"=>album.id})
      expect(history_tracks[3].modified).to eq({})
    end
  end
end