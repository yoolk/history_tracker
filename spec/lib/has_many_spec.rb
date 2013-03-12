require "spec_helper"

describe "Has Many Association" do
  before(:each) do
    @listing = Listing.create!(name: 'MongoDB 101', view_count: 101)
  end

  context "when created" do
    it "should record changes" do
      expect {
        @listing.comments.create!(title: 'Good Listing', body: 'Awesome')
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = @listing.comments.create!(title: 'Good Listing', body: 'Awesome')

      tracked = comment.history_tracks.last
      tracked.should be_present
      tracked.association_chain.should == [{"id"=>@listing.id, "name"=>"Listing"},{"id"=>comment.id, "name"=>"comments"}]
      tracked.modifier.should == {"id"=>1, "email"=>"chamnap@yoolk.com"}
      tracked.original.should == {}
      tracked.modified.should == {"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>@listing.id}
      tracked.action.should   == "create"
      tracked.scope.should    == "listing"
    end

    it "should retrieve changes from parent" do
      comment = @listing.comments.create!(title: 'Good Listing', body: 'Awesome')

      @listing.history_tracks.count.should == 2
      @listing.history_tracks[0].modified.should == {"name"=>"MongoDB 101", "view_count"=>101}
      @listing.history_tracks[1].modified.should == {"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>@listing.id}
    end
  end

  context "when updated" do
    it "track changes when child record is updated" do
      comment = @listing.comments.create!(title: 'Good Listing', body: 'Awesome')

      expect {
        comment.update_attributes!(title: 'Awesome Listing', body: 'Awesome Author')
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = @listing.comments.create!(title: 'Good Listing', body: 'Awesome')
      comment.update_attributes!(title: 'Awesome Listing', body: 'Awesome Author')

      comment.history_tracks.count.should == 2
      comment.history_tracks[0].modified.should == {"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>@listing.id}
      comment.history_tracks[1].modified.should == {"title"=>"Awesome Listing", "body"=>"Awesome Author"}
    end

    it "should retrieve changes from parent" do
      comment = @listing.comments.create!(title: 'Good Listing', body: 'Awesome')
      comment.update_attributes!(title: 'Awesome Listing', body: 'Awesome Author')

      @listing.history_tracks.count.should == 3
      @listing.history_tracks[0].modified.should == {"name"=>"MongoDB 101", "view_count"=>101}
      @listing.history_tracks[1].modified.should == {"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>@listing.id}
      @listing.history_tracks[2].modified.should == {"title"=>"Awesome Listing", "body"=>"Awesome Author"}
    end
  end

  context "when destroy" do
    it "track changes when child record is deleted" do
      comment = @listing.comments.create!(title: 'Good Listing', body: 'Awesome')

      expect {
        comment.destroy
      }.to change { Listing.history_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = @listing.comments.create!(title: 'Good Listing', body: 'Awesome')
      comment.destroy

      comment.history_tracks.count.should == 2
      comment.history_tracks[0].modified.should == {"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>@listing.id}
      comment.history_tracks[1].modified.should == {}
    end

    it "should retrieve changes from parent" do
      comment = @listing.comments.create!(title: 'Good Listing', body: 'Awesome')
      comment.destroy

      @listing.history_tracks.count.should == 3
      @listing.history_tracks[0].modified.should == {"name"=>"MongoDB 101", "view_count"=>101}
      @listing.history_tracks[1].modified.should == {"title"=>"Good Listing", "body"=>"Awesome", "listing_id"=>@listing.id}
      @listing.history_tracks[2].modified.should == {}
    end

    it "track changes when parent record is deleted" do
      comment = @listing.comments.create!(title: 'Good Listing', body: 'Awesome')

      expect {
        @listing.destroy
      }.to change { Listing.history_class.count }.by(2)
    end
  end
end