module Kino
  module Notifier
    class FileObserver
      NOTIFIABLE_FILE_EXTENSIONS = %w(md txt)

      def initialize(path, messaging_client = Kino::Notifier::MessagingClient.new)
        @path, @messaging_client, @notifier = \
          path, messaging_client, INotify::Notifier.new
      end

      def observe
        Dir["#{path}/*"].each do |path|
          notifier.watch(path, :create) do |event|
            if NOTIFIABLE_FILE_EXTENSIONS.include?(File.extname(event.name).gsub(/^\./, ''))
              full_filepath = Pathname.new(event.watcher.path).join(event.name)
              messaging_client.publish_message("file_created",
                "name" => event.name,
                "path" => event.watcher.path,
                "created_at" => File.stat(full_filepath.to_s).ctime.to_f,
                "contents" => File.read(full_filepath.to_s)
              )
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

      attr_reader :path, :messaging_client, :notifier
    end
  end
end
