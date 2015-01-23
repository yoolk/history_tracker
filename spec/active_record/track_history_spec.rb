require 'spec_helper'

describe '#track_history' do
  let(:listing) { Listing.create!(name: 'Listing 1') }
  let(:album)   { listing.albums.create!(name: 'Album 1') }
  let(:photo)   { album.photos.create!(caption: 'Photo 1') }

  context '#history_trackable_options' do
    it 'Listing model' do
      expect(Listing.history_trackable_options).to eq({:scope=>:listing, :on=>[:create, :update, :destroy], :changes_method=>:changes, :except=>["view_count"], :only=>[]})
    end

    it 'Album model' do
      expect(Album.history_trackable_options).to eq({:scope=>:listing, :on=>[:create, :update, :destroy], :changes_method=>:changes, :only=>["name"], :parent=>:listing, :inverse_of=>:albums, :except=>[]})
    end

    it 'Photo model' do
      expect(Photo.history_trackable_options).to eq({:scope=>:listing, :on=>[:create, :update, :destroy], :changes_method=>:changes, :parent=>:album, :inverse_of=>:photos, :only=>[], :except=>[]})
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

  context '#related_scope' do
    it 'Listing model' do
      expect(listing.send(:related_scope)).to eq(:listing)
    end

    it 'Album model' do
      expect(album.send(:related_scope)).to eq(:listing)
    end

    it 'Photo model' do
      expect(photo.send(:related_scope)).to eq(:album)
    end
  end
end