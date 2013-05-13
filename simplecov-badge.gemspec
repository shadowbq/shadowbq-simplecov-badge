# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'simplecov-badge/version'

Gem::Specification.new do |s|
  s.name        = "simplecov-badge"
  s.version     = SimpleCov::Formatter::BadgeFormatter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Hale"]
  s.email       = ["matt.hale.0 at gmail dot com"]
  s.homepage    = "https://github.com/BlackBoxAviation/simplecov-badge"
  s.summary     = %Q{HTML formatter for SimpleCov code coverage tool for ruby 1.9+}
  s.description = %Q{HTML formatter for SimpleCov code coverage tool for ruby 1.9+}

  s.rubyforge_project = "simplecov-badge"
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sprockets'
  s.add_development_dependency 'sass'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end