class BookHistory
  include HistoryTracker::Mongoid::Tracker
  store_in collection: 'book_histories'
end