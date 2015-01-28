require 'spec_helper'

describe 'modified_attributes' do
  context '#modified_attributes_for_create' do
    let!(:location)                     { Location.create!(name: 'Location 1', description: 'Description 1') }
    let(:listing)                       { Listing.new(name: 'Listing 1', description: 'Description 1', location: location) }
    let(:location_modified_attributes)  { location.send(:modified_attributes_for_create) }
    let(:listing_modified_attributes)   { listing.send(:modified_attributes_for_create) }

    it 'returns changeset which excludes only non_tracked_fields' do
      expect(location_modified_attributes).to eq({"name"=>[nil, "Location 1"], "description"=>[nil, "Description 1"]})
    end

    it 'invokes changes_method' do
      expect(listing_modified_attributes).to eq({"name"=>[nil, "Listing 1"], "description"=>[nil, "Description 1"], "is_active"=>[nil, nil], "location_id"=>[nil, listing.location_id], "location"=>[nil, listing.location.name]})
    end
  end

  context '#modified_attributes_for_update' do
    let!(:location1)                    { Location.create!(name: 'Location 1', description: 'Description 1') }
    let!(:location2)                    { Location.create!(name: 'Location 2', description: 'Description 2') }
    let!(:listing)                      { Listing.create!(name: 'Listing 1', description: 'Description 1', location: location1) }
    let(:location_modified_attributes)  { location1.send(:modified_attributes_for_update) }
    let(:listing_modified_attributes)   { listing.send(:modified_attributes_for_update) }

    it 'returns changeset which includes only the modified fields' do
      location1.assign_attributes(name: 'Location 2', description: 'Description 2')

      expect(location_modified_attributes).to eq({"name"=>["Location 1", "Location 2"], "description"=>["Description 1", "Description 2"]})
    end

    it 'invokes changes_method' do
      listing.assign_attributes(name: 'Listing 2', description: 'Description 2', location: location2)

      expect(listing_modified_attributes).to eq({"name"=>["Listing 1", "Listing 2"], "description"=>["Description 1", "Description 2"],"location_id"=>[1, 2],"location"=>["Location 1", "Location 2"]})
    end
  end

  context '#modified_attributes_for_destroy' do
    let!(:location)                     { Location.create!(name: 'Location 1', description: 'Description 1') }
    let!(:listing)                      { Listing.create!(name: 'Listing 1', description: 'Description 1', location: location) }
    let(:location_modified_attributes)  { location.send(:modified_attributes_for_destroy) }
    let(:listing_modified_attributes)   { listing.send(:modified_attributes_for_destroy) }

    it 'returns changeset which includes all fields' do
      expect(location_modified_attributes).to eq({"id"=>[location.id, nil], "name"=>["Location 1", nil], "description"=>["Description 1", nil]})
    end

    it 'invokes changes_method' do
      expect(listing_modified_attributes).to eq({"id"=>[listing.id, nil], "name"=>["Listing 1", nil], "description"=>["Description 1", nil], "is_active"=>[nil, nil], "created_at"=>[listing.created_at, nil], "updated_at"=>[listing.updated_at, nil], "location_id"=>[listing.location_id, nil], "location"=>[listing.location.name, nil]})
    end
  end

  context 'delegate methods' do
    let(:listing)  { Listing.new(name: 'Listing 1', description: 'Description 1') }

    it 'respond_to :history_trackable_options' do
      expect(listing).to respond_to(:history_trackable_options)
    end

    it 'respond_to :tracked_fields' do
      expect(listing).to respond_to(:tracked_fields)
    end

    it 'respond_to :non_tracked_fields' do
      expect(listing).to respond_to(:non_tracked_fields)
    end

    it 'respond_to :history_tracker_class' do
      expect(listing).to respond_to(:history_tracker_class)
    end

    it 'respond_to :track_history?' do
      expect(listing).to respond_to(:track_history?)
    end
  end
end