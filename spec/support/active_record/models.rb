# User model
class User < ActiveRecord::Base
end

# Models
class Location < ActiveRecord::Base
  has_many      :listings

  track_history
end

class Listing < ActiveRecord::Base
  belongs_to    :location
  has_many      :albums
  has_many      :photos, through: :albums

  track_history except: :view_count,
                changes_method: :history_changes

  def location_was
    Location.where(id: location_id_was).first
  end

  def location_changed?
    location_id_changed?
  end

  def history_changes
    if location_changed?
      changes.merge(location: [location_was.try(:name), location.try(:name)])
    elsif changes.blank?
      changes.merge(location: [location.try(:name), nil])
    else
      changes
    end
  end
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