# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'history_tracker/version'

Gem::Specification.new do |gem|
  gem.name          = "history_tracker"
  gem.version       = HistoryTracker::VERSION
  gem.authors       = ["chamnap", "vorleak"]
  gem.email         = ["chamnapchhorn@gmail.com", "vorleak.chy@gmail.com"]
  gem.description   = %q{A Simple gem that track changes your ActiveRecord models and stores those data in MongoDB}
  gem.summary       = %q{Track changes ActiveRecord models and stores in MongoDB}
  gem.homepage      = "https://github.com/yoolk/history_tracker"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "pry", "~> 0.9.12"
  gem.add_development_dependency "rspec", "~> 2.12.0"
  gem.add_development_dependency "sqlite3", "~> 1.3.7"

  gem.add_dependency "activerecord", "~> 3.2.12"
  gem.add_dependency "mongoid", "~> 3.1.1"
end
