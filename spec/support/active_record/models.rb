# User model
class User < ActiveRecord::Base
end

# has_many relation
class Listing < ActiveRecord::Base
  has_many :comments, :dependent => :destroy
  has_many :albums, :dependent => :destroy
  has_many :images, :through => :albums
  track_history
end

class Comment < ActiveRecord::Base
  belongs_to :listing
  track_history scope: :listing
end

# :class_name options
class ListingClassName < ActiveRecord::Base
  self.table_name = :listings
  track_history class_name: 'ListingHistory'
end

# :only options
class ListingOnly < ActiveRecord::Base
  self.table_name = :listings
  track_history only: [:name]
end

# :except options
class ListingExcept < ActiveRecord::Base
  self.table_name = :listings
  track_history except: [:name]
end

class ListingExceptAll < ActiveRecord::Base
  self.table_name = :listings
  track_history except: [:name, :description, :view_count, :is_active, :location_id]
end

# :create callback
class ListingOnCreate < ActiveRecord::Base
  self.table_name = :listings
  track_history on: [:create]
end

# :update callback
class ListingOnUpdate < ActiveRecord::Base
  self.table_name = :listings
  track_history on: [:update]
end

# :destroy callback
class ListingOnDestroy < ActiveRecord::Base
  self.table_name = :listings
  track_history on: [:destroy]
end

# :include options
class Location < ActiveRecord::Base
  self.table_name = :locations
end

class ListingInclude < ActiveRecord::Base
  self.table_name = :listings
  belongs_to :location
  track_history include: [:location]
end

class ListingIncludeFields < ActiveRecord::Base
  self.table_name = :listings
  belongs_to :location
  track_history include: [:location => [:name]]
end

# nested relation
class Album < ActiveRecord::Base
  belongs_to :listing
  has_many :images
  track_history scope: :listing
end

class Image < ActiveRecord::Base
  belongs_to :album

  track_history scope: :listing,
    class_name: 'Listing::History',
    association_chain: lambda { |record|
      [ {id: record.album.listing.id, name: 'Listing'}, {id: record.album.id, name: 'albums'}, {id: record.id, name: 'images'} ]
    }
end