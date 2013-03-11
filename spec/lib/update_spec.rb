require 'spec_helper'

describe 'Tracking changes when update' do
  context "when enabled" do
    it 'should record changes when update' do
      book = Book.create!(name: 'MongoDB 102', read_count: 102)
      expect {
        book.update_attributes!(name: 'MongoDB 201', read_count: 103)
      }.to change { Book.history_class.count }.by(1)
    end

    it 'should retrieve changes history' do
      book = Book.create!(name: 'MongoDB 102', read_count: 102)
      book.update_attributes!(name: 'MongoDB 201', read_count: 103)

      tracked = book.history_tracks.last
      tracked.should be_present
      # tracked.version.should  == 1
      tracked.original.should == {"name"=>"MongoDB 102", "read_count"=>102}
      tracked.modified.should == {"name"=>"MongoDB 201", "read_count"=>103}
      tracked.changeset.should == {"name"=>["MongoDB 102", "MongoDB 201"], "read_count"=>[102, 103]}
      tracked.action.should   == "update"
      tracked.scope.should    == "book"
    end

    it 'should track changes with :class_name' do
      book = BookClassName.create!(name: 'MongoDB 101', read_count: 101)

      expect {
        book.update_attributes!(name: 'MongoDB 102', read_count: 102)
      }.to change { BookHistory.count }.by(1)
    end

    it 'should track changes with :only options' do
      book = BookOnly.create!(name: 'MongoDB 101', read_count: 101)
      book.update_attributes!(name: 'MongoDB 102', read_count: 102)

      book.history_tracks.last.original.should == {"name"=>"MongoDB 101"}
      book.history_tracks.last.modified.should == {"name"=>"MongoDB 102"}
      book.history_tracks.last.changeset.should == {"name"=>["MongoDB 101", "MongoDB 102"]}
    end

    it 'should track changes with :except options' do
      book = BookExcept.create!(name: 'MongoDB 101', read_count: 101)
      book.update_attributes!(name: 'MongoDB 102', read_count: 102)

      book.history_tracks.last.original.should == {"read_count"=>101}
      book.history_tracks.last.modified.should == {"read_count"=>102}
      book.history_tracks.last.changeset.should == {"read_count"=>[101, 102]}
    end

    it 'should not track changes with :except, all columns' do
      book = BookExceptAll.create!(name: 'MongoDB 101', read_count: 101)

      expect {
        book.update_attributes!(name: 'MongoDB 102', read_count: 102)
      }.to change { BookExceptAll.history_class.count }.by(0)
    end

    it 'should track changes with on: [:update]' do
      book = BookOnUpdate.new(name: 'MongoDB 101', description: 'Open source document database', is_active: true, read_count: 5)

      expect { book.save }.to_not change { BookOnUpdate.history_class.count }.by(1)
      expect { book.update_attributes!(name: 'MongoDB 102') }.to change { BookOnUpdate.history_class.count }
      expect { book.destroy }.to_not change { BookOnUpdate.history_class.count }
    end
  end

  context "when disabled" do
    before(:each) do
      @book = Book.create!(name: 'MongoDB 101', read_count: 101)
    end

    after(:each) do
      Book.enable_tracking
    end
    
    it "should not track changes" do
      Book.disable_tracking

      expect {
        @book.update_attributes!(name: 'MongoDB 102', read_count: 102)
      }.to change { Book.history_class.count }.by(0)
    end

    it "should not track #without_tracking without :save" do
      @book.name = 'MongoDB 102'
      expect { @book.without_tracking { @book.save } }.to change { Book.history_class.count }.by(0)
    end

    it "should not track #without_tracking with :save" do
      @book.name = 'MongoDB 102'
      expect { @book.without_tracking(:save) }.to change { Book.history_class.count }.by(0)
    end
  end
end