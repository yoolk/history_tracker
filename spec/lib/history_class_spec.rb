require 'spec_helper'

describe 'History class' do
  it 'returns its history class from active record model' do
    Book.history_class.name.should == 'Book::History'
    BookOnly.history_class.name.should == 'BookOnly::History'
    BookExcept.history_class.name.should == 'BookExcept::History'
  end

  it 'should access from instance object' do
    Book.new.history_class.name.should == 'Book::History'
    BookOnly.new.history_class.name.should == 'BookOnly::History'
    BookExcept.new.history_class.name.should == 'BookExcept::History'
  end

  it 'stores in a collection name the same as its class name' do
    Book.history_class.collection_name.should == :book_histories
    BookOnly.history_class.collection_name.should == :book_only_histories
    BookExcept.history_class.collection_name.should == :book_except_histories
  end

  it 'should use specified class_name for storing' do
    BookClassName.history_class.name.should == 'BookHistory'
  end

  it 'returns tracked columns' do
    Book.tracked_columns.should == ["name", "description", "is_active", "read_count"]
  end

  it 'returns non tracked columns' do
    Book.non_tracked_columns.should == ["id", "lock_version", "created_at", "updated_at", "created_on", "updated_on"]
  end

  it 'should include some columns to track with `:only`' do
    BookOnly.tracked_columns.should == ["name"]
    BookOnly.non_tracked_columns.should_not include "name"
  end

  it 'should exclude some columns to track with `:except`' do
    BookExcept.tracked_columns.should_not include "name"
    BookExcept.non_tracked_columns.should include "name"
  end
end