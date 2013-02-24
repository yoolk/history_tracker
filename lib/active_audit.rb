require 'active_audit/version'
require 'active_support/concern'

module ActiveAudit
  class << self
    attr_accessor :ignored_attributes, :current_user_method
  end

  @ignored_attributes = %w(lock_version created_at updated_at created_on updated_on)

  @current_user_method = :current_user

  def current_user
    send(:"#{current_user_method}")
  end
end

require 'active_audit/active_record'
require 'active_audit/mongoid'