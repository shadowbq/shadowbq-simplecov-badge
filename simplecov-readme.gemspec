# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'simplecov-readme/version'

Gem::Specification.new do |s|
  s.name        = "simplecov-readme"
  s.version     = SimpleCov::Formatter::ReadmeFormatter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Hale"]
  s.email       = ["mhale at blackboxaviation dot com"]
  s.homepage    = "https://github.com/BlackBoxAviation/simplecov-readme"
  s.summary     = %Q{HTML formatter for SimpleCov code coverage tool for ruby 1.9+}
  s.description = %Q{HTML formatter for SimpleCov code coverage tool for ruby 1.9+}

  s.rubyforge_project = "simplecov-readme"
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sprockets'
  s.add_development_dependency 'sass'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end