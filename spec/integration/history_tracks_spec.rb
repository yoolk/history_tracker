require 'spec_helper'

describe Photo, '#history_tracks' do
  let!(:listing1) { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let!(:listing2) { Listing.create!(name: 'Listing 2', description: 'Description 2') }
  let!(:album1)   { listing1.albums.create!(name: 'Album 1') }
  let!(:album2)   { listing2.albums.create!(name: 'Album 2') }
  let!(:photo1)   { album1.photos.create!(caption: 'Caption 1') }
  let!(:photo2)   { album2.photos.create!(caption: 'Caption 2') }

  context 'Listing' do
    it 'includes all children\'s track' do
      expect(listing1.history_tracks.count).to eq(3)
    end

    it 'includes Listing\'s track' do
      expect(listing1.history_tracks[0].trackable_class_name).to eq('Listing')
    end

    it 'includes Album\'s track' do
      expect(listing1.history_tracks[1].trackable_class_name).to eq('Album')
    end

    it 'includes Photo\'s track' do
      expect(listing1.history_tracks[2].trackable_class_name).to eq('Photo')
    end
  end

  context 'Album' do
    it 'includes all children\'s track' do
      expect(album1.history_tracks.count).to eq(2)
    end

    it 'includes Album\'s track' do
      expect(album1.history_tracks[0].trackable_class_name).to eq('Album')
    end

    it 'includes Photo\'s track' do
      expect(album1.history_tracks[1].trackable_class_name).to eq('Photo')
    end
  end

  context 'Photo' do
    it 'includes its track' do
      expect(photo1.history_tracks.count).to eq(1)
    end

    it 'includes Photo\'s track' do
      expect(photo1.history_tracks[0].trackable_class_name).to eq('Photo')
    end
  end
end