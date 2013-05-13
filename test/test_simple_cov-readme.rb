require 'helper'

class TestSimpleCovBadge < Test::Unit::TestCase
  def test_defined
    assert defined?(SimpleCov::Formatter::BadgeFormatter)
    assert defined?(SimpleCov::Formatter::BadgeFormatter::VERSION)
  end
end
