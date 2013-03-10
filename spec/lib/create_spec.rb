require 'spec_helper'

describe 'Tracking changes when create' do
  context "when enabled" do
    it 'should track changes' do
      book = Book.new(name: 'MongoDB 101', description: 'Open source document database', is_active: true, read_count: 5)

      expect { book.save }.to change { Book.audit_class.count }.by(1)
    end

    it 'should retrieve changes history' do
      book = Book.create!(name: 'MongoDB 101', description: 'Open source document database', is_active: true, read_count: 5)

      audited = book.audited_changes.last
      audited.should be_present
      # audited.version.should  == 1
      audited.original.should == {}
      audited.modified.should == {"name"=>"MongoDB 101", "description"=>"Open source document database", "is_active"=>true, "read_count"=>5}
      audited.action.should   == "create"
      audited.scope.should    == "book"
    end

    it 'should track changes with :class_name' do
      expect {
        BookClassName.create!(name: 'MongoDB 101', read_count: 101)
      }.to change { BookHistory.count }.by(1)
    end

    it 'should track changes with :only options' do
      book = BookOnly.create!(name: 'MongoDB 101', read_count: 101)

      book.audited_changes.last.original.should == {}
      book.audited_changes.last.modified.should == {"name"=>"MongoDB 101"}
    end

    it 'should track changes with :except options' do
      book = BookExcept.create!(name: 'MongoDB 101', read_count: 101)

      book.audited_changes.last.original.should == {}
      book.audited_changes.last.modified.should == {"read_count"=>101}
    end

    it 'should track change with on: [:create]' do
      book = BookOnCreate.new(name: 'MongoDB 101', description: 'Open source document database', is_active: true, read_count: 5)

      expect { book.save }.to change { BookOnCreate.audit_class.count }.by(1)
      expect { book.update_attributes(name: 'MongoDB 102') }.to_not change { BookOnCreate.audit_class.count }
      expect { book.destroy }.to_not change { BookOnCreate.audit_class.count }
    end
  end

  context "when disabled" do
    after(:each) do
      Book.enable_tracking
    end

    it "should not track" do
      Book.disable_tracking

      expect {
        Book.create!(name: 'MongoDB 101', description: 'Open source document database', is_active: true, read_count: 5)
      }.to change { Book.audit_class.count }.by(0)
    end

    it "should not track #without_tracking without :save" do
      book = Book.new(name: 'MongoDB 101')
      expect { book.without_tracking { book.save! } }.to change { Book.audit_class.count }.by(0)
    end

    it "should not track #without_tracking with :save" do
      book = Book.new(name: 'MongoDB 101')
      expect { book.without_tracking(:save) }.to change { Book.audit_class.count }.by(0)
    end
  end
end