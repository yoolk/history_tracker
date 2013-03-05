require 'spec_helper'

describe 'Audit Log' do
  context 'setup' do
    it 'should return true for audited class' do
      Book.audit?.should be_true
    end

    it 'should return false for non-audited class' do
      class NonAuditedBook < ActiveRecord::Base; end
      
      NonAuditedBook.audit?.should be_false
    end
  end

  context 'Tracking changes' do
    context "when create" do
      it 'should record changes when create' do
        book = Book.new(name: 'MongoDB 101', description: 'Open source document database', is_active: true, read_count: 5)

        expect { book.save }.to change { Book.audit_class.count }.by(1)
      end

      it 'should retrieve changes history' do
        book = Book.new(name: 'MongoDB 101', description: 'Open source document database', is_active: true, read_count: 5)
        book.save

        audited = book.audited_changes.last
        audited.should be_present
        # audited.version.should  == 1
        audited.original.should == {}
        audited.modified.should == {"name"=>"MongoDB 101", "description"=>"Open source document database", "is_active"=>true, "read_count"=>5}
        audited.action.should   == "create"
        audited.scope.should    == "book"
      end
    end

    context "when update" do
      before(:each) do
        @book = Book.create!(name: 'MongoDB 102', read_count: 102)
      end

      it 'should record changes when update' do
        expect {
          @book.update_attributes!(name: 'MongoDB 201', read_count: 103)
        }.to change { Book.audit_class.count }.by(1)
      end

      it 'should retrieve changes history' do
        @book.update_attributes!(name: 'MongoDB 201', read_count: 103)

        audited = @book.audited_changes.last
        audited.should be_present
        # audited.version.should  == 1
        audited.original.should == {"name"=>"MongoDB 102", "read_count"=>102}
        audited.modified.should == {"name"=>"MongoDB 201", "read_count"=>103}
        audited.action.should   == "update"
        audited.scope.should    == "book"
      end
    end
    
    context "when destroy" do
      before(:each) do
        @book = Book.create!(name: 'MongoDB 102', read_count: 102)
      end

      it 'should record changes when destroy' do
        expect {
          @book.destroy
        }.to change { Book.audit_class.count }.by(1)
      end

      it 'should retrieve changes history' do
        @book.destroy

        audited = @book.audited_changes.last
        audited.should be_present
        # audited.version.should  == 1
        audited.original.should == {}
        audited.modified.should include({"id"=>6, "name"=>"MongoDB 102", "read_count"=>102})
        audited.action.should   == "destroy"
        audited.scope.should    == "book"
      end
    end
  end
end