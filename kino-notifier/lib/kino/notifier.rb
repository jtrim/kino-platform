require "bunny"
require "statsd"

require "kino/notifier/version"
require "kino/notifier/messaging_client"

module Kino
  module Notifier
    class << self
      attr_accessor :stats
    end
    self.stats = Statsd.new('localhost', 8125).tap{|sd| sd.namespace = "kino.notifier" }
  end
end
