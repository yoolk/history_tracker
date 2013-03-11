require 'spec_helper'

describe 'History class' do
  it 'returns its history class from active record model' do
    Listing.history_class.name.should == 'Listing::History'
    ListingOnly.history_class.name.should == 'ListingOnly::History'
    ListingExcept.history_class.name.should == 'ListingExcept::History'
  end

  it 'should access from instance object' do
    Listing.new.history_class.name.should == 'Listing::History'
    ListingOnly.new.history_class.name.should == 'ListingOnly::History'
    ListingExcept.new.history_class.name.should == 'ListingExcept::History'
  end

  it 'stores in a collection name the same as its class name' do
    Listing.history_class.collection_name.should == :listing_histories
    ListingOnly.history_class.collection_name.should == :listing_only_histories
    ListingExcept.history_class.collection_name.should == :listing_except_histories
  end

  it 'should use specified class_name for storing' do
    ListingClassName.history_class.name.should == 'ListingHistory'
  end

  it 'returns tracked columns' do
    Listing.tracked_columns.should == ["name", "description", "is_active", "view_count"]
  end

  it 'returns non tracked columns' do
    Listing.non_tracked_columns.should == ["id", "lock_version", "created_at", "updated_at", "created_on", "updated_on"]
  end

  it 'should include some columns to track with `:only`' do
    ListingOnly.tracked_columns.should == ["name"]
    ListingOnly.non_tracked_columns.should_not include "name"
  end

  it 'should exclude some columns to track with `:except`' do
    ListingExcept.tracked_columns.should_not include "name"
    ListingExcept.non_tracked_columns.should include "name"
  end
end