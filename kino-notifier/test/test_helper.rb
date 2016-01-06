$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "kino-notifier"
require "minitest/autorun"
require "fileutils"
require "pry"

Dir[Kino::Notifier.root.join(*%w(test support **/*.rb))].each {|f| require f }

module Minitest::Assertions
  def assert_hash_includes(expected, actual)
    intersection = Hash[expected.to_a & actual.to_a]
    assert_equal expected, intersection
  end
end
