require 'spec_helper'

describe Album, 'ActiveRecord Extensions' do
  context '#database_field_name' do
    it 'column name as symbol' do
      expect(Album.database_field_name(:name)).to eq('name')
    end

    it 'column name as string' do
      expect(Album.database_field_name('name')).to eq('name')
    end

    it 'belongs_to' do
      expect(Album.database_field_name(:listing)).to eq('listing_id')
    end

    it 'invalid column' do
      expect(Album.database_field_name(:unknown)).to eq(nil)
    end
  end
end