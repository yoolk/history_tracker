# User model
class User < ActiveRecord::Base
end

# Models
class Location < ActiveRecord::Base
  has_many      :listings
end

class Listing < ActiveRecord::Base
  belongs_to    :location
  has_many      :albums
  has_many      :photos, through: :albums

  track_history except: :view_count
end

class Album < ActiveRecord::Base
  belongs_to    :listing
  has_many      :photos

  track_history only: :name,
                parent: :listing,
                inverse_of: :albums,
                class_name: 'ListingHistoryTracker'
end

class Photo < ActiveRecord::Base
  belongs_to    :album

  track_history parent: :album,
                inverse_of: :photos,
                class_name: 'ListingHistoryTracker'
end