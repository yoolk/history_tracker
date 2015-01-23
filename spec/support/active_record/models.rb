# User model
class User < ActiveRecord::Base
end

# Models
class Listing < ActiveRecord::Base
  has_many      :albums
  has_many      :photos, through: :albums

  track_history except: :view_count
end

class Album < ActiveRecord::Base
  belongs_to    :listing
  has_many      :photos

  track_history scope: :listing,
                only: :name,
                parent: :listing,
                inverse_of: :albums
end

class Photo < ActiveRecord::Base
  belongs_to    :album

  track_history scope: :listing,
                parent: :album,
                inverse_of: :photos
end