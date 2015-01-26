require 'spec_helper'

describe Listing, 'track on create' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let(:history_track) { listing.history_tracks.first }

  it 'should have one history_track' do
    expect(listing.history_tracks.count).to eq(1)
  end

  it 'should be instance_of ListingHistoryTracker' do
    expect(history_track).to be_instance_of(ListingHistoryTracker)
  end

  it 'should have trackable_class_name' do
    expect(history_track.trackable_class_name).to eq('Listing')
  end

  it 'should have association_chain' do
    expected = [{ "name"=>"Listing", "id"=>listing.id }]

    expect(history_track.association_chain).to eq(expected)
  end

  it 'should have original field' do
    expect(history_track.original).to eq({})
  end

  it 'should have modified field' do
    expect(history_track.modified).to eq({"name"=>"Listing 1", "description"=>"Description 1"})
  end

  it 'should have action' do
    expect(history_track.action).to eq('create')
  end

  it 'should have trackable_class_name' do
    expect(history_track.trackable_class_name).to eq('Listing')
  end

  it 'shoud have modifier field' do
    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end

describe Album, 'track on create' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let!(:album)        { listing.albums.create!(name: 'Album 1') }
  let(:history_track) { album.history_tracks.first }

  it 'should have one history_track' do
    expect(album.history_tracks.count).to eq(1)
  end

  it 'should be instance_of ListingHistoryTracker' do
    expect(history_track).to be_instance_of(ListingHistoryTracker)
  end

  it 'should have trackable_class_name' do
    expect(history_track.trackable_class_name).to eq('Album')
  end

  it 'should have association_chain' do
    expected =  [ { "name"=>"Listing", "id"=>listing.id },
                  { "name"=>"albums", "id"=>album.id }
                ]

    expect(history_track.association_chain).to eq(expected)
  end

  it 'should have original field' do
    expect(history_track.original).to eq({})
  end

  it 'should have modified field' do
    expect(history_track.modified).to eq({"name"=>"Album 1"})
  end

  it 'should have action' do
    expect(history_track.action).to eq('create')
  end

  it 'should have action' do
    expect(history_track.trackable_class_name).to eq('Album')
  end

  it 'shoud have modifier field' do
    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end

describe Photo, 'track on create' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let!(:album)        { listing.albums.create!(name: 'Album 1') }
  let!(:photo)        { album.photos.create!(caption: 'Caption 1') }
  let(:history_track) { photo.history_tracks.first }

  it 'should have one history_track on `photo`' do
    expect(photo.history_tracks.count).to eq(1)
  end

  it 'should be instance_of ListingHistoryTracker' do
    expect(history_track).to be_instance_of(ListingHistoryTracker)
  end

  it 'should have trackable_class_name' do
    expect(history_track.trackable_class_name).to eq('Photo')
  end

  it 'should have association_chain' do
    expected =  [ { "name"=>"Listing", "id"=>listing.id },
                  { "name"=>"albums", "id"=>album.id },
                  {"name"=>"photos", "id"=>photo.id}
                ]

    expect(history_track.association_chain).to eq(expected)
  end

  it 'should have original field' do
    expect(history_track.original).to eq({})
  end

  it 'should have modified field' do
    expect(history_track.modified).to eq({"caption"=>"Caption 1", "album_id"=>album.id})
  end

  it 'should have action' do
    expect(history_track.action).to eq('create')
  end

  it 'should have action' do
    expect(history_track.trackable_class_name).to eq('Photo')
  end

  it 'shoud have modifier field' do
    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end