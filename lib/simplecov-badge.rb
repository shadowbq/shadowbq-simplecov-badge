# Ensure we are using a compatible version of SimpleCov
if Gem::Version.new(SimpleCov::VERSION) < Gem::Version.new("0.7.1")
  raise RuntimeError, "The version of SimpleCov you are using is too old. Please update with `gem install simplecov` or `bundle update simplecov`"
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))
require 'simplecov-badge/version'
require 'simplecov-badge/formatter.rb'