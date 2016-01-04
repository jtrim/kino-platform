$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "kino-notifier"
require "minitest/autorun"
require "fileutils"
require "pry"

Dir[Kino::Notifier.root.join(*%w(test support **/*.rb))].each {|f| require f }
