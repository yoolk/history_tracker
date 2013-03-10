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

  context 'Disable/Enable flag per model' do
    after(:each) do
      Book.enable_tracking
    end

    it 'should enable tracking by default' do
      Book.track_history?.should be_true
    end

    it 'should disable tracking' do
      Book.disable_tracking
      Book.track_history?.should be_false
    end

    it 'should enable tracking' do
      Book.disable_tracking
      Book.track_history?.should be_false

      Book.enable_tracking
      Book.track_history?.should be_true
    end

    it 'should disable tracking with block' do
      expect {
        Book.without_tracking { Book.create(name: 'MongoDB 101') }
      }.to change { Book.audit_class.count }.by(0)
      Book.track_history?.should be_true
    end
  end

  context "Enable/Disable globally" do
    after(:each) do
      ActiveAudit.enabled = true
      Book.enable_tracking
    end

    it 'should enable by default' do
      ActiveAudit.enabled?.should be_true
    end

    it 'should disable tracking' do
      ActiveAudit.enabled = false

      ActiveAudit.enabled?.should be_false
      Book.track_history?.should be_false
    end

    it 'should follow global setting' do
      ActiveAudit.enabled = false
      Book.enable_tracking
      ActiveAudit.enabled?.should be_false
      Book.track_history?.should be_false

      ActiveAudit.enabled = true
      Book.disable_tracking
      ActiveAudit.enabled?.should be_true
      Book.track_history?.should be_false

      ActiveAudit.enabled = true
      Book.enable_tracking
      ActiveAudit.enabled?.should be_true
      Book.track_history?.should be_true
    end
  end
end