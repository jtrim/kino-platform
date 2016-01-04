class TestMessagingClient
  attr_accessor :payloads

  def initialize
    @payloads = {}
  end

  def publish_message(queue, payload)
    payloads[queue] ||= []
    payloads[queue] << payload
  end

  def payloads_for_queue?(queue)
    !payloads[queue].nil? && !payloads[queue].empty?
  end
end
