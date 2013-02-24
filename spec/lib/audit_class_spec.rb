require 'spec_helper'

describe 'Audit class' do
  it 'returns its audit class from active record model' do
    Book.audit_class.name.should == 'Book::Audit'
  end

  it 'should access from instance object' do
    Book.new.audit_class.name.should == 'Book::Audit'
  end

  it 'store in a collection name the same as its class name' do
    Book.audit_class.collection_name.should == :book_audits
  end
end