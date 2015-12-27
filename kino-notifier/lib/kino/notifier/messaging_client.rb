module Kino
  module Notifier
    class MessagingClient
      def initialize(queue_name, logger = Logger.new($stdout))
        @queue_name, @connection, @logger = queue_name, Bunny.new, logger
      end

      def publish_message(message)
        with_channel do |ch, q|
          ch.default_exchange.publish(message, routing_key: q.name, persistent: true)
          log_message_published(message, q)
        end
      end

      def consume
        with_channel do |ch, q|
          begin
            q.subscribe(block: true, manual_ack: true) do |delivery_info, properties, body|
              yield body
              ch.ack(delivery_info.delivery_tag)
            end
          rescue SignalException => e
            logger.info "Shutting down consumer..."
            connection.close
            raise
          end
        end
      end

      private

      attr_reader :queue_name, :connection, :logger

      def with_channel
        channel = connection.tap(&:start).create_channel
        queue   = channel.queue(@queue_name, durable: true)
        yield channel, queue
        connection.close
      end

      def log_message_published(message, q)
        truncated_message = \
          if message.size > 20
            "#{message[0..20]}..."
          else
            message
          end
        logger.info("#{self.class.name}: Published '#{truncated_message}' to #{q.name}")
      end
    end
  end
end
