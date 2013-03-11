class Listing < ActiveRecord::Base
  has_many :comments, :dependent => :destroy
  track_history
end

class Comment < ActiveRecord::Base
  belongs_to :listing
  track_history scope: :listing
end

class ListingClassName < ActiveRecord::Base
  self.table_name = :listings
  track_history class_name: 'ListingHistory'
end

class ListingOnly < ActiveRecord::Base
  self.table_name = :listings
  track_history only: [:name]
end

class ListingExcept < ActiveRecord::Base
  self.table_name = :listings
  track_history except: [:name]
end

class ListingExceptAll < ActiveRecord::Base
  self.table_name = :listings
  track_history except: [:name, :description, :view_count, :is_active]
end

class ListingOnCreate < ActiveRecord::Base
  self.table_name = :listings
  track_history on: [:create]
end

class ListingOnUpdate < ActiveRecord::Base
  self.table_name = :listings
  track_history on: [:update]
end

class ListingOnDestroy < ActiveRecord::Base
  self.table_name = :listings
  track_history on: [:destroy]
end

class Location < ActiveRecord::Base
  self.table_name = :locations
end

class ListingInclude < ActiveRecord::Base
  self.table_name = :listings
  belongs_to :location
  track_history include: [:location]
end