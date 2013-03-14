# HistoryTracker

HistoryTracker tracks historical changes for any active record models, including its associations, and stores in MongoDB. It achieves this by storing all history tracks in a single collection that you define. Association models are referenced by storing an association path, which is an array of `model_name` and `model_id` fields starting from the top most parent and down to the assoication that should track history.

## Installation

This gem depends on ActiveRecord 3.x and Mongoid 3.x. It's well tested on Ruby 1.9.3 only.

    gem 'history_tracker', :git => 'git@github.com:yoolk/history_tracker.git'

## Usage

#### Tracker class name

By default, an active record model will have `history_class` pointed to eg. `Listing::History`.

    # app/models/listing.rb
    class Listing < ActiveRecord::Base
      track_history
    end

    >> Listing.history_class # => Listing::History

However, you can specify the history class name with `:class_name` options. All histories related to this model are stored in this tracker class.

    # app/models/listing.rb
    class Listing < ActiveRecord::Base
      track_history class_name: 'Listing::HistoryTracker'
    end

    # app/models/listing/history_tracker.rb
    class Listing::HistoryTracker
      include HistoryTracker::Mongoid::Tracker
    end

    >> Listing.history_class # => Listing::HistoryTracker

#### #current_user method name

By default, this gem will invoke `current_user` method and save its id and attributes on each change. However, you can change it by sets the `current_user_method` using a Rails initializer.

    # config/initializers/history_tracker.rb
    HistoryTracker.current_user_method = :authenticated_user

    # Assume that current_user returns #<User id: 1, email: 'chamnap@yoolk.com'>
    >> listing = Listing.first
    >> listing.update_attributes(name: 'New Name')

    >> listing.history_tracks.last.modifier    #=> {"id" => 1, "email" => "chamnap@yoolk.com"}
    >> listing.history_tracks.last.modifier_id #=> 1

#### Simple Model

HistoryTracker is simple to use. Just call `track_history` to a model to track changes on every create, update, and destroy.

    # app/models/listing.rb
    class Listing < ActiveRecord::Base

      # should put below association
      track_history   :scope      => "listing",                       # scope, default is the underscore version of this model
                      :class_name => "Listing::History"               # specify the tracker class name, default is the newly mongoid class with "::History" suffix
                      :only       => [:name],                         # track only the specified fields
                      :except     => [],                              # track all fields except the specified fields 
                      :on         => [:create, :update, :destroy],    # by default, it tracks all events
                      :include    => [],                              # track :belongs_to association
                      :association_chain => lambda { |record| [] }    # specify association_chain for complex relations
    end

This gives you a `history_tracks` method which returns historical changes to your model.

    # Assume that current_user returns #<User id: 1, email: 'chamnap@yoolk.com'>
    >> listing = Listing.create(name: 'Listing 1')
    >> track = listing.history_tracks.last
    >> track.scope      #=> listing
    >> track.action     #=> create
    >> track.modifier   #=> {"id" => 1, "email" => "chamnap@yoolk.com"}
    >> track.original   #=> {}
    >> track.modified   #=> {"name": "Listing 1"}
    >> track.changeset  #=> {"name": [nil, "Listing 1"]}

    >> listing.update_attributes(name: 'New Listing 1')
    >> track = listing.history_tracks.last
    >> track.scope      #=> listing
    >> track.action     #=> update
    >> track.modifier   #=> {"id" => 1, "email" => "chamnap@yoolk.com"}
    >> track.original   #=> {"id" => 1, "name" => "Listing 1", "created_at"=>2013-03-12 06:25:51 UTC, "updated_at"=>2013-03-12 06:44:37 UTC}
    >> track.modified   #=> {"name" => "New Listing 1"}
    >> track.changeset  #=> {"name": ["Listing 1", "New Listing 1"]}

    >> listing.destroy
    >> track = listing.history_tracks.last
    >> track.scope      #=> listing
    >> track.action     #=> destroy
    >> track.modifier   #=> {"id" => 1, "email" => "chamnap@yoolk.com"}
    >> track.original   #=> {"id" => 1, "name" => "Listing 1", "created_at"=>2013-03-12 06:25:51 UTC, "updated_at"=>2013-03-12 06:44:37 UTC}
    >> track.modified   #=> {}
    >> track.changeset  #=> {}

#### Relation: `belongs_to`, `has_one` and `has_many`

    # app/models/location.rb
    class Location < ActiveRecord::Base
    end

    # app/models/listing.rb
    class Listing < ActiveRecord::Base
      belongs_to :location
      has_many   :comments, :dependent => :destroy

      track_history  include: [:location]
    end

    # app/models/comment.rb
    class Comment < ActiveRecord::Base
      belongs_to :listing

      track_history  scope:      :listing,           # must have a :belongs_to association
                     class_name: 'Listing::History'  # for direct relation, it's optional
    end

    >> phnom_penh = Location.create(name: 'Phnom Penh')
    >> siem_reap  = Location.create(name: 'Siem Reap')
    >> listing = Listing.create(name: 'Listing 1', location: phnom_penh)
    >> comment = listing.comments.create(body: 'Good listing')

    >> comment.history_tracks.count #=> 1
    >> listing.history_tracks.count #=> 2, including :comments

    >> listing.update_attributes(location: siem_reap)
    >> track = listing.history_tracks.last
    >> track.original  # {"location"=>{"id"=>1, "name"=>"Phnom Penh"}}
    >> track.modified  # {"location"=>{"id"=>2, "name"=>"Siem Reap"}}
    >> track.changeset # {"location"=>[{"id"=>1, "name"=>"Phnom Penh"}, {"id"=>2, "name"=>"Siem Reap"}]}

#### Nested Relation

For complex or nested relation, specify `:class_name` and `:association_chain` manually. For more examples, check out [spec/lib/nested_spec.rb] (https://github.com/yoolk/history_tracker/blob/master/spec/lib/nested_spec.rb).

## Enable/Disable Tracking

Sometimes you don't want to store changes. Perhaps you are only interested in changes made by your users and don't need to store changes you make yourself in, say, a migration -- or when testing your application.

You can enable or disable tracking in three ways: globally, per class, or per method call.

#### Globally

On a global level you can disable tracking like this:

    >> HistoryTracker.enabled = false

For example, you might want to disable tracking in your Rails application's test environment to speed up your tests. This will do it:

    # in config/environments/test.rb
    config.after_initialize do
      HistoryTracker.enabled = false
    end

#### Per class

If you are about change some widgets and you don't want to track your changes, you can disable tracking like this:

    >> Listing.disable_tracking

And enable back like this:

    >> Listing.enable_tracking

#### Per method call

You can call a method without tracking changes using `without_tracking`. It takes either a method name as a symbol:

    @listing.without_tracking :destroy

Or a block:

    @listing.without_tracking do
      @listing.update_attributes :name => 'New Listing 1'
    end

## Authors

* [Chamnap Chhorn](https://github.com/chamnap)
* [Vorleak Chy](https://github.com/vorleakchy)