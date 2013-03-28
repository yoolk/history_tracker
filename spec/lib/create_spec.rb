require 'spec_helper'

describe 'Tracking changes when create' do
  context "when enabled" do
    it 'should track changes' do
      listing = Listing.new(name: 'MongoDB 101', description: 'Open source document database', is_active: true, view_count: 5)

      expect { listing.save }.to change { Listing.history_class.count }.by(1)
    end

    it 'should retrieve changes history' do
      listing = Listing.create!(name: 'MongoDB 101', description: 'Open source document database', is_active: true, view_count: 5)

      tracked = listing.history_tracks.last
      tracked.should be_present
      tracked.modifier.should == {"id"=>1, "email"=>"chamnap@yoolk.com"}
      tracked.original.should == {}
      tracked.modified.should == {"name"=>"MongoDB 101", "description"=>"Open source document database", "is_active"=>true, "view_count"=>5}
      tracked.changeset.should be_equal({"name"=>[nil, "MongoDB 101"], "description"=>[nil, "Open source document database"], "is_active"=>[nil, true], "view_count"=>[nil, 5]})
      tracked.action.should   == "create"
      tracked.scope.should    == "listing"
    end

    it 'should track changes with :class_name' do
      expect {
        ListingClassName.create!(name: 'MongoDB 101', view_count: 101)
      }.to change { ListingHistory.count }.by(1)
    end

    it 'should track changes with :only options' do
      listing = ListingOnly.create!(name: 'MongoDB 101', view_count: 101)

      listing.history_tracks.last.original.should == {}
      listing.history_tracks.last.modified.should == {"name"=>"MongoDB 101"}
      listing.history_tracks.last.changeset.should == {"name"=>[nil, "MongoDB 101"]}
    end

    it 'should track changes with :except options' do
      listing = ListingExcept.create!(name: 'MongoDB 101', description: 'A comprehensive listing', is_active: true, view_count: 101)

      listing.history_tracks.last.original.should == {}
      listing.history_tracks.last.modified.should == {"description"=>"A comprehensive listing", "is_active"=>true, "view_count"=>101}
      listing.history_tracks.last.changeset.should == {"description"=>[nil, "A comprehensive listing"], "is_active"=>[nil, true], "view_count"=>[nil, 101]}
    end

    it 'should track change with on: [:create]' do
      listing = ListingOnCreate.new(name: 'MongoDB 101', description: 'Open source document database', is_active: true, view_count: 5)

      expect { listing.save }.to change { ListingOnCreate.history_class.count }.by(1)
      expect { listing.update_attributes(name: 'MongoDB 102') }.to_not change { ListingOnCreate.history_class.count }
      expect { listing.destroy }.to_not change { ListingOnCreate.history_class.count }
    end
  end

  context "when disabled" do
    after(:each) do
      Listing.enable_tracking
    end

    it "should not track" do
      Listing.disable_tracking

      expect {
        Listing.create!(name: 'MongoDB 101', description: 'Open source document database', is_active: true, view_count: 5)
      }.to change { Listing.history_class.count }.by(0)
    end

    it "should not track #without_tracking without :save" do
      listing = Listing.new(name: 'MongoDB 101')
      expect { listing.without_tracking { listing.save! } }.to change { Listing.history_class.count }.by(0)
    end

    it "should not track #without_tracking with :save" do
      listing = Listing.new(name: 'MongoDB 101')
      expect { listing.without_tracking(:save) }.to change { Listing.history_class.count }.by(0)
    end
  end

  context "#create_history_track" do
    it "should not create history_track" do
      listing = ListingNoCallback.create!(name: 'MongoDB 101', description: 'Open source document database', is_active: true, view_count: 5)

      listing.history_tracks.count.should == 0
    end

    it "should create history_track on :create" do
      listing = ListingNoCallback.create!(name: 'MongoDB 101', description: 'Open source document database', is_active: true, view_count: 5)

      expect {
        listing.create_history_track(:create, listing.previous_changes)
      }.to change { listing.history_tracks.count }.by(1)
    end

    it "should create history_track with different modifier" do
      listing = ListingNoCallback.create!(name: 'MongoDB 101', description: 'Open source document database', is_active: true, view_count: 5)
      user    = User.create!(id: 1, email: 'chamnapchhorn@gmail.com')

      expect {
        listing.create_history_track(:create, listing.previous_changes, user)
      }.to change { listing.history_tracks.count }.by(1)
    end

    it "should create history_track on :update" do
      listing = ListingNoCallback.create!(name: 'MongoDB 101', description: 'Open source document database', is_active: true, view_count: 5)
      listing.update_attributes(name: 'MongoDB 102')

      expect {
        listing.create_history_track(:update, listing.previous_changes)
      }.to change { listing.history_tracks.count }.by(1)
    end

    it "should create history_track on :destroy" do
      listing = ListingNoCallback.create!(name: 'MongoDB 101', description: 'Open source document database', is_active: true, view_count: 5)
      listing.destroy

      expect {
        changes = {
          "name"=>["MongoDB 101", nil],
          "description"=>["Open source document database", nil],
          "is_active"=>[true, nil],
          "view_count"=>[5, nil],
          "id"=>[4, nil]
        }
        listing.create_history_track(:destroy, changes)
      }.to change { listing.history_tracks.count }.by(1)
    end
  end
end