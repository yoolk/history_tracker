require 'spec_helper'

describe Listing, 'track on update' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let(:history_track) { listing.history_tracks.last }

  it 'create history track if the changed attributes match the tracked attributes' do
    expect {
      listing.update_attributes!(name: 'Listing 2', description: 'Description 2')
    }.to change(ListingHistoryTracker, :count).by(1)
  end

  it 'doesn\'t create history track if it didn\'t match' do
    expect {
      listing.update_attributes!(view_count: 1)
    }.to change(ListingHistoryTracker, :count).by(0)
  end

  it 'should have trackable_class_name' do
    expect(history_track.trackable_class_name).to eq('Listing')
  end

  it 'should have association_chain' do
    expected = [{ "name"=>"Listing", "id"=>listing.id }]

    expect(history_track.association_chain).to eq(expected)
  end

  it 'should have modified fields' do
    listing.update_attributes!(name: 'Listing 2', description: 'Description 2')

    expect(history_track.modified).to eq('name'=>'Listing 2', 'description'=>'Description 2')
  end

  it 'should have original fields' do
    listing.update_attributes!(name: 'Listing 2', description: 'Description 2')

    expect(history_track.original).to eq('name'=>'Listing 1', 'description'=>'Description 1')
  end

  it 'should have action field' do
    listing.update_attributes!(name: 'Listing 2', description: 'Description 2')

    expect(history_track.action).to eq('update')
  end

  it 'should have modifier field' do
    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end

describe Album, 'track on update' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let!(:album)        { listing.albums.create!(name: 'Album 1') }
  let(:history_track) { album.history_tracks.last }

  it 'create history track if the changed attributes match the tracked attributes' do
    expect {
      album.update_attributes!(name: 'Album 2')
    }.to change(ListingHistoryTracker, :count).by(1)
  end

  it 'should have trackable_class_name' do
    expect(history_track.trackable_class_name).to eq('Album')
  end

  it 'should have association_chain' do
    expected =  [
                  { "name"=>"Listing", "id"=>listing.id },
                  { "name"=>"albums", "id"=>album.id }
                ]

    expect(history_track.association_chain).to eq(expected)
  end

  it 'should have modified fields' do
    album.update_attributes!(name: 'Album 2')

    expect(history_track.modified).to eq({"name"=>"Album 2"})
  end

  it 'should have original fields' do
    album.update_attributes!(name: 'Album 2')

    expect(history_track.original).to eq({"name"=>"Album 1"})
  end

  it 'should have action field' do
    album.update_attributes!(name: 'Album 2')

    expect(history_track.action).to eq('update')
  end

  it 'should have modifier field' do
    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end

describe Photo, 'track on update' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let!(:album)        { listing.albums.create!(name: 'Album 1') }
  let!(:photo)        { album.photos.create!(caption: 'Caption 1') }
  let(:history_track) { photo.history_tracks.last }

  it 'create history track if the changed attributes match the tracked attributes' do
    expect {
      photo.update_attributes!(caption: 'Caption 2')
    }.to change(ListingHistoryTracker, :count).by(1)
  end

  it 'should have trackable_class_name' do
    expect(history_track.trackable_class_name).to eq('Photo')
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
    photo.update_attributes!(caption: 'Caption 2')

    expect(history_track.modified).to eq({"caption"=>"Caption 2"})
  end

  it 'should have original fields' do
    photo.update_attributes!(caption: 'Caption 2')

    expect(history_track.original).to eq({"caption"=>"Caption 1"})
  end

  it 'should have action field' do
    photo.update_attributes!(caption: 'Caption 2')

    expect(history_track.action).to eq('update')
  end

  it 'should have modifier field' do
    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end