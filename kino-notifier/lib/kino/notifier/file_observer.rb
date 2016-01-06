module Kino
  module Notifier
    class FileObserver
      NOTIFIABLE_FILE_EXTENSIONS = %w(md txt)
      class ZeroLengthFileError < RuntimeError; end

      def initialize(path, messaging_client = Kino::Notifier::MessagingClient.new, logger = Logger.new($stdout))
        @path, @messaging_client, @notifier, @logger = \
          path, messaging_client, INotify::Notifier.new, logger
      end

      def observe
        Dir["#{path}/*"].each do |path|
          notifier.watch(path, :create) do |event|
            if NOTIFIABLE_FILE_EXTENSIONS.include?(File.extname(event.name).gsub(/^\./, ''))
              Thread.new do
                tries = 0
                begin
                  full_filepath = Pathname.new(event.watcher.path).join(event.name)
                  contents = File.read(full_filepath.to_s)
                  raise ZeroLengthFileError if contents.empty?
                  messaging_client.publish_message("file_created",
                    "name" => event.name,
                    "path" => event.watcher.path,
                    "created_at" => File.stat(full_filepath.to_s).ctime.to_f,
                    "contents" => contents
                  )
                rescue
                  if (tries += 1) <= 3
                    sleep 0.1
                    retry
                  else
                    logger.warn("Zero length file written to disk at #{full_filepath}, ignoring...")
                  end
                end
              end
            end
          end

          Dir["#{path}/*.{md,txt}"].each do |filepath|
            notifier.watch(filepath, :close_write) do |event|
              full_filepath = Pathname.new(event.watcher.path).join(event.name)
              messaging_client.publish_message("file_modified",
                "name" => event.name,
                "path" => event.watcher.path,
                "modified_at" => File.stat(full_filepath.to_s).mtime.to_f,
                "contents" => File.read(full_filepath.to_s)
              )
            end
          end
        end

        notifier.run
      end

      private

      attr_reader :path, :messaging_client, :notifier, :logger
    end
  end
end
