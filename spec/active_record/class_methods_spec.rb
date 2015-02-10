require 'spec_helper'

describe 'ClassMethods' do
  context '#history_tracker_class' do
    class MyListing < ActiveRecord::Base
      self.table_name = 'listings'

      track_history class_name: 'ListingHistoryTracker'
    end

    class MyAlbum < ActiveRecord::Base
      self.table_name = 'ablums'
      belongs_to    :my_listing

      track_history scope: :my_listing
    end

    class AnotherListing < ActiveRecord::Base
      self.table_name = 'listings'

      track_history
    end

    it 'returns tracker_class from :class_name' do
      expect(MyListing.history_tracker_class).to eq(ListingHistoryTracker)
    end

    it 'returns tracker_class from deferred' do
      expect(AnotherListing.history_tracker_class).to eq(AnotherListingHistoryTracker)
      expect(AnotherListing.history_tracker_class.collection_name).to eq(:listing_histories)
    end
  end

  context '#tracked_fields, #non_tracked_fields' do
    it 'except option' do
      expect(Listing.tracked_fields).to eq(['name', 'description', 'is_active', 'location_id'])
      expect(Listing.non_tracked_fields).to eq(['id', 'lock_version', 'created_at', 'updated_at', 'created_on', 'updated_on', 'view_count'])
    end

    it 'only option' do
      expect(Album.tracked_fields).to eq(['name'])
      expect(Album.non_tracked_fields).to eq(['id', 'created_at', 'updated_at', 'listing_id'])
    end

    it 'all' do
      expect(Photo.tracked_fields).to eq(['caption', 'album_id'])
      expect(Photo.non_tracked_fields).to eq(['id', 'lock_version', 'created_at', 'updated_at', 'created_on', 'updated_on'])
    end
  end

  context '#tracked_fields_for_action' do
    it 'doesn\'t include ignored field for create action' do
      expect(Photo.tracked_fields_for_action(:create)).to eq(['caption', 'album_id'])
    end

    it 'doesn\'t include ignored field for update action' do
      expect(Photo.tracked_fields_for_action(:update)).to eq(['caption', 'album_id'])
    end

    it 'includes ignored field for destroy action' do
      expect(Photo.tracked_fields_for_action(:destroy)).to eq(['caption', 'album_id', 'id', 'lock_version', 'created_at', 'updated_at', 'created_on', 'updated_on'])
    end
  end

  context '#tracked_field?' do
    it 'doesn\'t include ignored field by default' do
      expect(Photo.tracked_field?(:id)).to eq(false)
    end

    it 'include ignored field for destroy action' do
      expect(Photo.tracked_field?(:id, :destroy)).to eq(true)
    end
  end
end