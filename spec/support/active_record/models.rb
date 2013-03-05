class Book < ActiveRecord::Base
  has_many :comments, :dependent => :destroy
  audit_trail
end

class Comment < ActiveRecord::Base
  belongs_to :book
  audit_trail scope: :book
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