require 'spec_helper'

describe Listing, 'track on update' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let(:history_track) { listing.history_tracks.updates.first }

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

  it 'should have trackable_klass_name' do
    listing.update_attributes!(name: 'Listing 2', description: 'Description 2')

    expect(history_track.trackable_klass_name).to eq('Listing')
  end

  it 'should have association_chain' do
    listing.update_attributes!(name: 'Listing 2', description: 'Description 2')
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

  it 'should have changes field' do
    listing.update_attributes!(name: 'Listing 2', description: 'Description 2')

    expect(history_track.changes).to eq({"name"=>["Listing 1", "Listing 2"], "description"=>["Description 1", "Description 2"]})
  end

  it 'should have action field' do
    listing.update_attributes!(name: 'Listing 2', description: 'Description 2')

    expect(history_track.action).to eq('update')
  end

  it 'should have modifier field' do
    listing.update_attributes!(name: 'Listing 2', description: 'Description 2')

    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end

describe Album, 'track on update' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let!(:album)        { listing.albums.create!(name: 'Album 1') }
  let(:history_track) { album.history_tracks.updates.first }

  it 'create history track if the changed attributes match the tracked attributes' do
    expect {
      album.update_attributes!(name: 'Album 2')
    }.to change(ListingHistoryTracker, :count).by(1)
  end

  it 'should have trackable_klass_name' do
    album.update_attributes!(name: 'Album 2')

    expect(history_track.trackable_klass_name).to eq('Album')
  end

  it 'should have association_chain' do
    album.update_attributes!(name: 'Album 2')

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

  it 'should have changes field' do
    album.update_attributes!(name: 'Album 2')

    expect(history_track.changes).to eq({"name"=>["Album 1", "Album 2"]})
  end

  it 'should have action field' do
    album.update_attributes!(name: 'Album 2')

    expect(history_track.action).to eq('update')
  end

  it 'should have modifier field' do
    album.update_attributes!(name: 'Album 2')

    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end

describe Photo, 'track on update' do
  let!(:listing)      { Listing.create!(name: 'Listing 1', description: 'Description 1') }
  let!(:album)        { listing.albums.create!(name: 'Album 1') }
  let!(:photo)        { album.photos.create!(caption: 'Caption 1') }
  let(:history_track) { photo.history_tracks.updates.first }

  it 'create history track if the changed attributes match the tracked attributes' do
    expect {
      photo.update_attributes!(caption: 'Caption 2')
    }.to change(ListingHistoryTracker, :count).by(1)
  end

  it 'should have trackable_klass_name' do
    photo.update_attributes!(caption: 'Caption 2')

    expect(history_track.trackable_klass_name).to eq('Photo')
  end

  it 'should have association_chain' do
    photo.update_attributes!(caption: 'Caption 2')

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

  it 'should have changes field' do
    photo.update_attributes!(caption: 'Caption 2')

    expect(history_track.changes).to eq({"caption"=>["Caption 1", "Caption 2"]})
  end

  it 'should have action field' do
    photo.update_attributes!(caption: 'Caption 2')

    expect(history_track.action).to eq('update')
  end

  it 'should have modifier field' do
    photo.update_attributes!(caption: 'Caption 2')

    expect(history_track.modifier_id).to eq(HistoryTracker.current_modifier_id)
  end
end