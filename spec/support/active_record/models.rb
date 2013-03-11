class Book < ActiveRecord::Base
  has_many :comments, :dependent => :destroy
  track_history
end

class Comment < ActiveRecord::Base
  belongs_to :book
  track_history scope: :book
end

class BookClassName < ActiveRecord::Base
  self.table_name = :books
  track_history class_name: 'BookHistory'
end

class BookOnly < ActiveRecord::Base
  self.table_name = :books
  track_history only: [:name]
end

class BookExcept < ActiveRecord::Base
  self.table_name = :books
  track_history except: [:name]
end

class BookExceptAll < ActiveRecord::Base
  self.table_name = :books
  track_history except: [:name, :description, :read_count, :is_active]
end

class BookOnCreate < ActiveRecord::Base
  self.table_name = :books
  track_history on: [:create]
end

class BookOnUpdate < ActiveRecord::Base
  self.table_name = :books
  track_history on: [:update]
end

class BookOnDestroy < ActiveRecord::Base
  self.table_name = :books
  track_history on: [:destroy]
end