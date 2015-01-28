require 'spec_helper'

describe 'modified_attributes' do
  context '#modified_attributes_for_create' do
    let(:listing) { Listing.new(name: 'Listing 1', description: 'Description 1') }
    subject       { listing.send(:modified_attributes_for_create) }

    it 'returns changeset which excludes only non_tracked_fields' do
      expect(subject).to eq({"name"=>[nil, "Listing 1"], "description"=>[nil, "Description 1"], "is_active"=>[nil, nil], "location_id"=>[nil, nil]})
    end
  end

  context '#modified_attributes_for_update' do
    let!(:listing) { Listing.create!(name: 'Listing 1', description: 'Description 1') }
    subject        { listing.send(:modified_attributes_for_update) }

    it 'returns changeset which includes only the modified fields' do
      listing.assign_attributes(name: 'Listing 2', description: 'Description 2')

      expect(subject).to eq({"name"=>["Listing 1", "Listing 2"], "description"=>["Description 1", "Description 2"]})
    end
  end

  context '#modified_attributes_for_destroy' do
    let!(:listing)  { Listing.create!(name: 'Listing 1', description: 'Description 1') }
    subject         { listing.send(:modified_attributes_for_destroy) }

    it 'returns changeset which includes all fields' do
      listing.assign_attributes(name: 'Listing 2', description: 'Description 2')

      expect(subject).to eq({"id"=>[listing.id, nil], "name"=>["Listing 2", nil], "description"=>["Description 2", nil], "is_active"=>[nil, nil], "created_at"=>[listing.created_at, nil], "updated_at"=>[listing.updated_at, nil], "location_id"=>[nil, nil]})
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