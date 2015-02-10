require 'spec_helper'

describe Listing, 'track on destroy' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let(:history_track) { listing.history_tracks.last }

  it 'create history track when destroy' do
    expect {
      listing.destroy
    }.to change(ListingHistoryTracker, :count).by(1)
  end

  it 'should have trackable_klass_name' do
    expect(history_track.trackable_klass_name).to eq('Listing')
  end

  it 'should have association_chain' do
    expected = [{ "name"=>"Listing", "id"=>listing.id }]

    expect(history_track.association_chain).to eq(expected)
  end

  it 'should have modified fields' do
    listing.destroy

    expect(history_track.modified).to eq({})
  end

  it 'should have original fields' do
    listing.destroy

    expect(history_track.original).to be_eql_hash('id' => listing.id, 'name'=>'Listing 1', 'description'=>'Description 1', 'created_at' => listing.created_at, 'updated_at' => listing.updated_at)
  end

  it 'should have action field' do
    listing.destroy

    expect(history_track.action).to eq('destroy')
  end

  it 'should have modifier field' do
    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end

describe Album, 'track on destroy' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let!(:album)        { listing.albums.create!(name: 'Album 1') }
  let(:history_track) { album.history_tracks.last }

  it 'create history track when destroy' do
    expect {
      album.destroy
    }.to change(ListingHistoryTracker, :count).by(1)
  end

  it 'should have trackable_klass_name' do
    expect(history_track.trackable_klass_name).to eq('Album')
  end

  it 'should have association_chain' do
    expected =  [
                  { "name"=>"Listing", "id"=>listing.id },
                  { "name"=>"albums", "id"=>album.id }
                ]

    expect(history_track.association_chain).to eq(expected)
  end

  it 'should have modified fields' do
    album.destroy

    expect(history_track.modified).to eq({})
  end

  it 'should have original fields' do
    album.destroy

    expect(history_track.original).to be_eql_hash('id' => album.id, 'name'=>'Album 1', 'created_at' => album.created_at, 'updated_at' => album.updated_at)
  end

  it 'should have action field' do
    album.destroy

    expect(history_track.action).to eq('destroy')
  end

  it 'should have modifier field' do
    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end

describe Photo, 'track on destroy' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let!(:album)        { listing.albums.create!(name: 'Album 1') }
  let!(:photo)        { album.photos.create!(caption: 'Caption 1') }
  let(:history_track) { photo.history_tracks.last }

  it 'create history track when destroy' do
    expect {
      photo.destroy
    }.to change(ListingHistoryTracker, :count).by(1)
  end

  it 'should have trackable_klass_name' do
    expect(history_track.trackable_klass_name).to eq('Photo')
  end

  it 'should have association_chain' do
    expected =  [
                  { "name"=>"Listing", "id"=>listing.id },
                  { "name"=>"albums", "id"=>album.id },
                  { "name"=>"photos", "id"=>photo.id }
                ]

    expect(history_track.association_chain).to eq(expected)
  end

  it 'should have modified fields' do
    photo.destroy

    expect(history_track.modified).to eq({})
  end

  it 'should have original fields' do
    photo.destroy

    expect(history_track.original).to be_eql_hash('id' => photo.id, 'caption'=>'Caption 1', 'created_at' => photo.created_at, 'updated_at' => photo.updated_at, "album_id"=>album.id)
  end

  it 'should have action field' do
    photo.destroy

    expect(history_track.action).to eq('destroy')
  end

  it 'should have modifier field' do
    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end