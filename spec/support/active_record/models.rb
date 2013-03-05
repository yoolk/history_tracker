class Book < ActiveRecord::Base
  audit_trail
end

class BookClassName < ActiveRecord::Base
  self.table_name = :books
  audit_trail class_name: 'BookHistory'
end

class BookOnly < ActiveRecord::Base
  self.table_name = :books
  audit_trail only: [:name]
end

class BookExcept < ActiveRecord::Base
  self.table_name = :books
  audit_trail except: [:name]
end

class BookOnCreate < ActiveRecord::Base
  self.table_name = :books
  audit_trail on: [:create]
end

class BookOnUpdate < ActiveRecord::Base
  self.table_name = :books
  audit_trail on: [:update]
end

class BookOnDestroy < ActiveRecord::Base
  self.table_name = :books
  audit_trail on: [:destroy]
end