require 'spec_helper'

class MyTracker
  include HistoryTracker::Mongoid::Tracker
end

describe MyTracker, type: :mongoid do
  it { should have_index_for('association_chain.id' => 1, 'association_chain.name' => 1).with_options(background: true) }
  it { should have_index_for(modifier_id: 1).with_options(background: true) }
  it { should have_index_for(trackable_klass_name: 1).with_options(background: true) }

  it { should have_field(:association_chain).of_type(Array) }
  it { should have_field(:original).of_type(Hash).with_default_value_of({}) }
  it { should have_field(:modified).of_type(Hash).with_default_value_of({}) }
  it { should have_field(:changeset).of_type(Hash).with_default_value_of({}).with_alias(:changes) }
  it { should have_field(:action).of_type(String) }
  it { should have_field(:modifier_id).of_type(Integer) }

  it { should validate_presence_of(:association_chain) }
  it { should validate_presence_of(:action) }
  it { should validate_presence_of(:modifier_id) }
  it { should validate_presence_of(:trackable_klass_name) }
  it { should validate_inclusion_of(:action).to_allow('create', 'update', 'destroy') }
end

describe MyTracker, 'methods' do
  let(:tracker) { MyTracker.new(action: 'update', original: {name: 'Listing 1'}, modified: {name: 'Listing 2'}) }

  it '#original should be stringify_keys' do
    expect(tracker.original).to eq({'name' => 'Listing 1'})
  end

  it '#modified should be stringify_keys' do
    expect(tracker.modified).to eq({'name' => 'Listing 2'})
  end

  context '#trackable' do
    let!(:listing)      { Listing.create!(name: 'Listing 1') }
    let(:history_track) { listing.history_tracks.first }

    it 'returns trackable' do
      expect(history_track.trackable).to eq(listing)
    end

    it 'returns trackable_class' do
      expect(history_track.trackable_class).to eq(Listing)
    end
  end
end