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

      tracked = comment.tracked_changes.last
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

      @book.tracked_changes.count.should == 2
      @book.tracked_changes[0].modified.should == {"name"=>"MongoDB 101", "read_count"=>101}
      @book.tracked_changes[1].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
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

      comment.tracked_changes.count.should == 2
      comment.tracked_changes[0].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      comment.tracked_changes[1].modified.should == {"title"=>"Awesome Book", "body"=>"Awesome Author"}
    end

    it "should retrieve changes from parent" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')
      comment.update_attributes!(title: 'Awesome Book', body: 'Awesome Author')

      @book.tracked_changes.count.should == 3
      @book.tracked_changes[0].modified.should == {"name"=>"MongoDB 101", "read_count"=>101}
      @book.tracked_changes[1].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      @book.tracked_changes[2].modified.should == {"title"=>"Awesome Book", "body"=>"Awesome Author"}
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

      comment.tracked_changes.count.should == 2
      comment.tracked_changes[0].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      comment.tracked_changes[1].modified.should include({"id"=>comment.id, "title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id})
    end

    it "should retrieve changes from parent" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')
      comment.destroy

      @book.tracked_changes.count.should == 3
      @book.tracked_changes[0].modified.should == {"name"=>"MongoDB 101", "read_count"=>101}
      @book.tracked_changes[1].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      @book.tracked_changes[2].modified.should include({"id"=>comment.id, "title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id})
    end

    it "track changes when parent record is deleted" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

      expect {
        @book.destroy
      }.to change { Book.history_class.count }.by(2)
    end
  end
end