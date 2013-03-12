require 'active_record'
require 'logger'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :locations, :force => true do |t|
    t.column :name, :string
    t.column :priority, :integer
  end

  create_table :listings, :force => true do |t|
    t.column :name, :string
    t.column :description, :string
    t.column :is_active, :boolean
    t.column :view_count, :integer
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
    t.column :location_id, :integer
  end

  create_table :comments, :force => true do |t|
    t.column :title, :string
    t.column :body, :string
    t.column :listing_id, :integer
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end

  create_table :albums, :force => true do |t|
    t.column :name, :string
    t.column :listing_id, :integer
  end

  create_table :images, :force => true do |t|
    t.column :caption, :string
    t.column :album_id, :integer
  end
end