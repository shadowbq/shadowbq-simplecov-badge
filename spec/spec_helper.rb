require 'rubygems'
require 'bundler/setup'
require 'simplecov'
SimpleCov.start do
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
       SimpleCov::Formatter::HTMLFormatter,
       SimpleCov::Formatter::ShadowbqBadgeFormatter,
     ]
end
require 'shadowbq-simplecov-badge'

RSpec.configure do |config|
  # some (optional) config here

end
