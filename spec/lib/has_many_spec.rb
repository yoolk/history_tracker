require "spec_helper"

describe "Has Many Association" do
  before(:each) do
    @book = Book.create!(name: 'MongoDB 101', read_count: 101)
  end

  context "when created" do
    it "should record changes" do
      expect {
        @book.comments.create!(title: 'Good Book', body: 'Awesome')
      }.to change { Book.audit_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

      audited = comment.audited_changes.last
      audited.should be_present
      audited.association_chain.should == [{"id"=>@book.id, "name"=>"Book"},{"id"=>comment.id, "name"=>"comments"}]
      # audited.version.should  == 1
      audited.original.should == {}
      audited.modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      audited.action.should   == "create"
      audited.scope.should    == "book"
    end

    it "should retrieve changes from parent" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

      @book.audited_changes.count.should == 2
      @book.audited_changes[0].modified.should == {"name"=>"MongoDB 101", "read_count"=>101}
      @book.audited_changes[1].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
    end
  end

  context "when updated" do
    it "track changes when child record is updated" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

      expect {
        comment.update_attributes!(title: 'Awesome Book', body: 'Awesome Author')
      }.to change { Book.audit_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')
      comment.update_attributes!(title: 'Awesome Book', body: 'Awesome Author')

      comment.audited_changes.count.should == 2
      comment.audited_changes[0].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      comment.audited_changes[1].modified.should == {"title"=>"Awesome Book", "body"=>"Awesome Author"}
    end

    it "should retrieve changes from parent" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')
      comment.update_attributes!(title: 'Awesome Book', body: 'Awesome Author')

      @book.audited_changes.count.should == 3
      @book.audited_changes[0].modified.should == {"name"=>"MongoDB 101", "read_count"=>101}
      @book.audited_changes[1].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      @book.audited_changes[2].modified.should == {"title"=>"Awesome Book", "body"=>"Awesome Author"}
    end
  end

  context "when destroy" do
    it "track changes when child record is deleted" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

      expect {
        comment.destroy
      }.to change { Book.audit_class.count }.by(1)
    end

    it "should retrieve changes from child" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')
      comment.destroy

      comment.audited_changes.count.should == 2
      comment.audited_changes[0].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      comment.audited_changes[1].modified.should include({"id"=>comment.id, "title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id})
    end

    it "should retrieve changes from parent" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')
      comment.destroy

      @book.audited_changes.count.should == 3
      @book.audited_changes[0].modified.should == {"name"=>"MongoDB 101", "read_count"=>101}
      @book.audited_changes[1].modified.should == {"title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id}
      @book.audited_changes[2].modified.should include({"id"=>comment.id, "title"=>"Good Book", "body"=>"Awesome", "book_id"=>@book.id})
    end

    it "track changes when parent record is deleted" do
      comment = @book.comments.create!(title: 'Good Book', body: 'Awesome')

      expect {
        @book.destroy
      }.to change { Book.audit_class.count }.by(2)
    end
  end
end