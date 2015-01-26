require 'spec_helper'

class MyTracker
  include HistoryTracker::Mongoid::Tracker
end

describe MyTracker, type: :mongoid do
  it { should have_index_for('association_chain.id' => 1, 'association_chain.name' => 1).with_options(background: true) }
  it { should have_index_for(modifier_id: 1).with_options(background: true) }
  it { should have_index_for(trackable_class_name: 1).with_options(background: true) }

  it { should have_field(:association_chain).of_type(Array) }
  it { should have_field(:original).of_type(Hash).with_default_value_of({}) }
  it { should have_field(:modified).of_type(Hash).with_default_value_of({}) }
  it { should have_field(:action).of_type(String) }
  it { should have_field(:modifier_id).of_type(Integer) }

  it { should validate_presence_of(:association_chain) }
  it { should validate_presence_of(:action) }
  it { should validate_presence_of(:modifier_id) }
  it { should validate_presence_of(:trackable_class_name) }
  it { should validate_inclusion_of(:action).to_allow('create', 'update', 'destroy') }
end