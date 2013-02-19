# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_audit/version'

Gem::Specification.new do |gem|
  gem.name          = "activeaudit"
  gem.version       = ActiveAudit::VERSION
  gem.authors       = ["chamnap", "vorleak"]
  gem.email         = ["chamnapchhorn@gmail.com", "vorleak.chy@gmail.com"]
  gem.description   = %q{ActiveAudit is a simple audit gem that allows you to track changes your ActiveRecord models and stores those data in MongoDB}
  gem.summary       = %q{Track changes ActiveRecord models and stores in MongoDB}
  gem.homepage      = "https://github.com/yoolk/active_audit"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "pry", "~> 0.9.12"
end
