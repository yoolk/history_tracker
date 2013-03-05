require 'active_record'
require 'logger'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :books, :force => true do |t|
    t.column :name, :string
    t.column :description, :string
    t.column :is_active, :boolean
    t.column :read_count, :integer
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end

  create_table :comments, :force => true do |t|
    t.column :title, :string
    t.column :body, :string
    t.column :book_id, :integer
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end
end