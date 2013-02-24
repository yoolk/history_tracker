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
end