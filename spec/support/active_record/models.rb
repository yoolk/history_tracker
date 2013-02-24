class Book < ActiveRecord::Base
  audit_trail
end

class BookOnly < ActiveRecord::Base
  self.table_name = :books
  audit_trail only: [:name]
end

class BookExcept < ActiveRecord::Base
  self.table_name = :books
  audit_trail except: [:name]
end