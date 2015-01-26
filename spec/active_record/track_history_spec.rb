require 'spec_helper'

describe '#track_history' do
  let(:listing) { Listing.create!(name: 'Listing 1') }
  let(:album)   { listing.albums.create!(name: 'Album 1') }
  let(:photo)   { album.photos.create!(caption: 'Photo 1') }

  context '#history_trackable_options' do
    it 'Listing model' do
      expect(Listing.history_trackable_options).to eq({:on=>[:create, :update, :destroy], :changes_method=>:changes, :except=>["view_count"], :only=>[]})
    end

    it 'Album model' do
      expect(Album.history_trackable_options).to eq({:on=>[:create, :update, :destroy], :changes_method=>:changes, :only=>["name"], :parent=>:listing, :inverse_of=>:albums, :class_name=>"ListingHistoryTracker", :except=>[]})
    end

    it 'Photo model' do
      expect(Photo.history_trackable_options).to eq({:on=>[:create, :update, :destroy], :changes_method=>:changes, :parent=>:album, :inverse_of=>:photos, :class_name=>"ListingHistoryTracker", :only=>[], :except=>[]})
    end
  end

  context '#history_trackable_parent' do
    it 'Listing model' do
      expect(listing.history_trackable_parent).to be_nil
    end

    it 'Album model' do
      expect(album.history_trackable_parent).to eq(listing)
    end

    it 'Photo model' do
      expect(photo.history_trackable_parent).to eq(album)
    end
  end

  context '#association_chain' do
    it 'Listing model' do
      expect(listing.association_chain).to eq([{"name"=>"Listing", "id"=>listing.id}])
    end

    it 'Album model' do
      expect(album.association_chain).to eq([{"name"=>"Listing", "id"=>listing.id}, {"name"=>"albums", "id"=>album.id}])
    end

    it 'Photo model' do
      expect(photo.association_chain).to eq([{"name"=>"Listing", "id"=>listing.id}, {"name"=>"albums", "id"=>album.id}, {"name"=>"photos", "id"=>photo.id}])
    end
  end

  context '#association_hash' do
    it 'Listing model' do
      expect(listing.send(:association_hash)).to eq({"name"=>"Listing", "id"=>listing.id})
    end

    it 'Album model' do
      expect(album.send(:association_hash)).to eq({"name"=>"albums", "id"=>album.id})
    end

    it 'Photo model' do
      expect(photo.send(:association_hash)).to eq({"name"=>"photos", "id"=>photo.id})
    end
  end

  context '#callbacks' do
    it 'should define callback function #track_update' do
      expect(Listing.new.private_methods.collect(&:to_sym)).to include(:track_update)
    end

    it 'should define callback function #track_create' do
      expect(Listing.new.private_methods.collect(&:to_sym)).to include(:track_create)
    end

    it 'should define callback function #track_destroy' do
      expect(Listing.new.private_methods.collect(&:to_sym)).to include(:track_destroy)
    end
  end
end