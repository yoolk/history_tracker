require 'spec_helper'

describe '#write_history_track!' do
  let!(:listing) { Listing.create!(name: 'Listing 1', description: 'Description 1') }

  context '#write_history_track! on :create' do
    it 'should create history_track' do
      expect {
        listing.write_history_track!(:create, { 'name' => [nil, 'Listing 2'], 'description' => [nil, 'Description 2'] })
      }.to change { listing.history_tracks.count }.by(1)
    end

    it "should create history_track with different modifier" do
      modifier = User.create!(email: 'chamnapchhorn@gmail.com')
      changes = { 'name' => [nil, 'Listing 2'], 'description' => [nil, 'Description 2'] }

      history_track = listing.write_history_track!(:create, changes, modifier.id)
      expect(history_track.modifier_id).to eq(modifier.id)
    end

    it 'should have original' do
      history_track = listing.write_history_track!(:create, { 'name' => [nil, 'Listing 2'], 'description' => [nil, 'Description 2'] })

      expect(history_track.original).to eq({})
    end

    it 'should have modified' do
      history_track = listing.write_history_track!(:create, { 'name' => [nil, 'Listing 2'], 'description' => [nil, 'Description 2'] })

      expect(history_track.modified).to eq({"name"=>"Listing 2", "description"=>"Description 2"})
    end
  end

  context '#write_history_track! on :update' do
    it "should create history_track" do
      history_track = listing.write_history_track!(:update, { 'name' => ['Listing 1', 'Listing 2'], 'description' => ['Description 1', 'Description 2'] })

      expect(history_track.original).to eq({"name"=>"Listing 1", "description"=>"Description 1"})
      expect(history_track.modified).to eq({"name"=>"Listing 2", "description"=>"Description 2"})
    end
  end

  context '#write_history_track! on :destroy' do
    it "should create history_track" do
      expect {
        listing.write_history_track!(:destroy)
      }.to change { listing.history_tracks.count }.by(1)
    end

    it 'should have original' do
      history_track = listing.write_history_track!(:destroy)

      expect(history_track.original).to be_eql_hash({"id"=>listing.id, "name"=>"Listing 1", "description"=>"Description 1", "created_at"=>listing.created_at, "updated_at"=>listing.created_at})
    end

    it 'should have modified' do
      history_track = listing.write_history_track!(:destroy)

      expect(history_track.modified).to eq({})
    end
  end
end