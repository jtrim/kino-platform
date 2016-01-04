require "pathname"

require "bunny"
require "statsd"
require "rb-inotify"
require "eventmachine"
require "oj"

require "kino/notifier/version"
require "kino/notifier/messaging_client"
require "kino/notifier/file_observer"

module Kino
  module Notifier
    class << self
      attr_accessor :stats
    end
    self.stats = Statsd.new((ENV['STATSD_HOST'] || 'localhost'), 8125).
      tap{|sd| sd.namespace = "kino.notifier" }

    def self.root
      Pathname.new \
        File.expand_path("../../..", __FILE__)
    end
  end
end
