require "spec_helper"

describe "Has Many Association" do
  before(:each) do
    @book = Book.create!(name: 'MongoDB 101', read_count: 101)
  end

  context "when created" do
    it "should record changes" do
      expect {
        @book.comments.create!(title: 'Good Book', body: 'Awesome')
      }.to change { Book.history_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

      tracked = comment.history_tracks.last
      tracked.should be_present
      tracked.association_chain.should == [{"id"=>@book.id, "name"=>"Book"},{"id"=>comment.id, "name"=>"comments"}]
      # tracked.version.should  == 1
      tracked.original.should == {}
      tracked.modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      tracked.action.should   == "create"
      tracked.scope.should    == "book"
    end

    it "should retrieve changes from parent" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

      @book.history_tracks.count.should == 2
      @book.history_tracks[0].modified.should == {"name"=>"MongoDB 101", "read_count"=>101}
      @book.history_tracks[1].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
    end
  end

  context "when updated" do
    it "track changes when child record is updated" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

      expect {
        comment.update_attributes!(title: 'Awesome Book', body: 'Awesome Author')
      }.to change { Book.history_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')
      comment.update_attributes!(title: 'Awesome Book', body: 'Awesome Author')

      comment.history_tracks.count.should == 2
      comment.history_tracks[0].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      comment.history_tracks[1].modified.should == {"title"=>"Awesome Book", "body"=>"Awesome Author"}
    end

    it "should retrieve changes from parent" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')
      comment.update_attributes!(title: 'Awesome Book', body: 'Awesome Author')

      @book.history_tracks.count.should == 3
      @book.history_tracks[0].modified.should == {"name"=>"MongoDB 101", "read_count"=>101}
      @book.history_tracks[1].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      @book.history_tracks[2].modified.should == {"title"=>"Awesome Book", "body"=>"Awesome Author"}
    end
  end

  context "when destroy" do
    it "track changes when child record is deleted" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

      expect {
        comment.destroy
      }.to change { Book.history_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')
      comment.destroy

      comment.history_tracks.count.should == 2
      comment.history_tracks[0].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      comment.history_tracks[1].modified.should == {}
    end

    it "should retrieve changes from parent" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')
      comment.destroy

      @book.history_tracks.count.should == 3
      @book.history_tracks[0].modified.should == {"name"=>"MongoDB 101", "read_count"=>101}
      @book.history_tracks[1].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      @book.history_tracks[2].modified.should == {}
    end

    it "track changes when parent record is deleted" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

      expect {
        @book.destroy
      }.to change { Book.history_class.count }.by(2)
    end
  end
end