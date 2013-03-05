class BookHistory
  include ActiveAudit::Mongoid::AuditTrail
  store_in collection: 'book_histories'
end