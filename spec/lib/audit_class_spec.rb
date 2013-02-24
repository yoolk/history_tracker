require 'spec_helper'

describe 'Audit class' do
  it 'returns its audit class from active record model' do
    Book.audit_class.name.should == 'Book::Audit'
    BookOnly.audit_class.name.should == 'BookOnly::Audit'
    BookExcept.audit_class.name.should == 'BookExcept::Audit'
  end

  it 'should access from instance object' do
    Book.new.audit_class.name.should == 'Book::Audit'
    BookOnly.new.audit_class.name.should == 'BookOnly::Audit'
    BookExcept.new.audit_class.name.should == 'BookExcept::Audit'
  end

  it 'stores in a collection name the same as its class name' do
    Book.audit_class.collection_name.should == :book_audits
    BookOnly.audit_class.collection_name.should == :book_only_audits
    BookExcept.audit_class.collection_name.should == :book_except_audits
  end

  it 'returns audited columns' do
    Book.audited_columns.should == ["name", "description", "is_active", "read_count"]
  end

  it 'returns non audited columns' do
    Book.non_audited_columns.should == ["id", "lock_version", "created_at", "updated_at", "created_on", "updated_on"]
  end

  it 'should include some columns to audit with `:only`' do
    BookOnly.audited_columns.should == ["name"]
    BookOnly.non_audited_columns.should_not include "name"
  end

  it 'should exclude some columns to audit with `:except`' do
    BookExcept.audited_columns.should_not include "name"
    BookExcept.non_audited_columns.should include "name"
  end
end