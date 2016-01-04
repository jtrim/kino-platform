module Kino
  module Notifier
    class MessagingClient
      def initialize(logger = Logger.new($stdout),
                     stats  = Kino::Notifier.stats,
                     host   = "localhost")
        @connection, @logger, @stats = \
          Bunny.new(host: ENV['RABBITMQ_HOST'] || host), logger, stats
      end

      def publish_message(queue_name, _message)
        message = formatted_message(_message)
        with_channel(queue_name) do |ch, q|
          ch.default_exchange.publish(message, routing_key: q.name, persistent: true)
          log_message_published(message, q)
          stats.increment("message.produced.#{q.name}")
          stats.count("message.produced.bytes.#{q.name}", message.bytesize)
        end
      end

      def consume(queue_name)
        with_channel(queue_name) do |ch, q|
          begin
            q.subscribe(block: true, manual_ack: true) do |delivery_info, properties, body|
              stats.time "message.consumed.#{q.name}" do
                yield body
              end
              ch.ack(delivery_info.delivery_tag)
              stats.increment("message.consumed.#{q.name}")
            end
          end
        end
      end

      private

      attr_reader :connection, :logger, :stats

      def formatted_message(message)
        if message.is_a? String
          message
        else
          Oj.dump(message)
        end
      end

      def with_channel(queue_name)
        channel = connection.tap(&:start).create_channel
        queue   = channel.queue(queue_name, durable: true)
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
