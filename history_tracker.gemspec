# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'history_tracker/version'

Gem::Specification.new do |spec|
  spec.name          = "history_tracker"
  spec.version       = HistoryTracker::VERSION
  spec.authors       = ["Chamnap Chhorn"]
  spec.email         = ["chamnapchhorn@gmail.com"]
  spec.summary       = %q{Track changes ActiveRecord models and stores in MongoDB}
  spec.description   = %q{A Simple gem that track changes your ActiveRecord models and stores those data in MongoDB}
  spec.homepage      = "https://github.com/yoolk/history_tracker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 3.2.15"
  spec.add_dependency "mongoid",      ">= 3.1.5"
end