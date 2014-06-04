require "spec_helper"

describe "Has Many Association" do
  let!(:listing) { Listing.create!(name: 'MongoDB 101', view_count: 101) }

  context "when created" do
    it "should record changes" do
      expect {
        listing.comments.create!(title: 'Good Listing', body: 'Awesome')
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = listing.comments.create!(title: 'Good Listing', body: 'Awesome')

      tracked = comment.history_tracks.last
      expect(tracked).to be_present
      expect(tracked.association_chain).to eq([{"id"=>listing.id, "name"=>"Listing"},{"id"=>comment.id, "name"=>"comments"}])
      expect(tracked.modifier).to eq({"id"=>1, "email"=>"chamnap@yoolk.com"})
      expect(tracked.original).to eq({})
      expect(tracked.modified).to eq({"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>listing.id})
      expect(tracked.action).to   eq("create")
      expect(tracked.scope).to    eq("listing")
      expect(tracked.type).to     eq("comments")
    end

    it "should retrieve changes from parent" do
      comment = listing.comments.create!(title: 'Good Listing', body: 'Awesome')

      history_tracks = listing.history_tracks(scope: true)
      expect(history_tracks.count).to eq(2)
      expect(history_tracks[0].modified).to eq({"name"=>"MongoDB 101", "view_count"=>101})
      expect(history_tracks[1].modified).to eq({"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>listing.id})
    end
  end

  context "when updated" do
    it "track changes when child record is updated" do
      comment = listing.comments.create!(title: 'Good Listing', body: 'Awesome')

      expect {
        comment.update_attributes!(title: 'Awesome Listing', body: 'Awesome Author')
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = listing.comments.create!(title: 'Good Listing', body: 'Awesome')
      comment.update_attributes!(title: 'Awesome Listing', body: 'Awesome Author')

      history_tracks = comment.history_tracks
      expect(history_tracks.count).to eq(2)
      expect(history_tracks[0].modified).to eq({"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>listing.id})
      expect(history_tracks[1].modified).to eq({"title"=>"Awesome Listing", "body"=>"Awesome Author"})
    end

    it "should retrieve changes from parent" do
      comment = listing.comments.create!(title: 'Good Listing', body: 'Awesome')
      comment.update_attributes!(title: 'Awesome Listing', body: 'Awesome Author')

      history_tracks = listing.history_tracks(scope: true)
      expect(history_tracks.count).to eq(3)
      expect(history_tracks[0].modified).to eq({"name"=>"MongoDB 101", "view_count"=>101})
      expect(history_tracks[1].modified).to eq({"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>listing.id})
      expect(history_tracks[2].modified).to eq({"title"=>"Awesome Listing", "body"=>"Awesome Author"})
    end
  end

  context "when destroy" do
    it "track changes when child record is deleted" do
      comment = listing.comments.create!(title: 'Good Listing', body: 'Awesome')

      expect {
        comment.destroy
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = listing.comments.create!(title: 'Good Listing', body: 'Awesome')
      comment.destroy

      history_tracks = comment.history_tracks(scope: true)
      expect(history_tracks.count).to eq(2)
      expect(history_tracks[0].modified).to eq({"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>listing.id})
      expect(history_tracks[1].modified).to eq({})
    end

    it "should retrieve changes from parent" do
      comment = listing.comments.create!(title: 'Good Listing', body: 'Awesome')
      comment.destroy

      history_tracks = listing.history_tracks(scope: true)
      expect(history_tracks.count).to eq(3)
      expect(history_tracks[0].modified).to eq({"name"=>"MongoDB 101", "view_count"=>101})
      expect(history_tracks[1].modified).to eq({"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>listing.id})
      expect(history_tracks[2].modified).to eq({})
    end

    it "track changes when parent record is deleted" do
      comment = listing.comments.create!(title: 'Good Listing', body: 'Awesome')

      expect {
        listing.destroy
      }.to change { Listing.history_class.count }.by(2)
    end
  end
end