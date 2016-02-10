# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'shadowbq-simplecov-badge/version'

Gem::Specification.new do |s|
  s.name        = "shadowbq-simplecov-badge"
  s.version     = SimpleCov::Formatter::ShadowbqBadgeFormatter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Hale"]
  s.email       = ["matt.hale.0 at gmail dot com"]
  s.homepage    = "https://github.com/shadowbq/shadowbq-simplecov-badge"
  s.summary     = %Q{Badge generator for SimpleCov code coverage tool for ruby 1.9+}
  s.description = %Q{Badge generator for SimpleCov code coverage tool for ruby 1.9+}
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
