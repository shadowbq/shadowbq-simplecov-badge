require 'helper'

class TestSimpleCovReadme < Test::Unit::TestCase
  def test_defined
    assert defined?(SimpleCov::Formatter::ReadmeFormatter)
    assert defined?(SimpleCov::Formatter::ReadmeFormatter::VERSION)
  end
end
