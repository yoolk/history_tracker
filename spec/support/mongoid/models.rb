class ListingHistory
  include HistoryTracker::Mongoid::Tracker
  store_in collection: 'listing_histories'
end