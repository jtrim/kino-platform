module Kino
  module Notifier
    class Observer
      def initialize(path)
        INotify::Notifier.new.tap do |notifier|
          Dir["#{path}/*"].map do |path|
            notifier.watch(path, :create) do |event|
              pathname = Pathname.new(event.watcher.path).join(event.name)
              if File.file? pathname.to_s
                Kino::Notifier::MessagingClient.new("file_created").publish_message(
                  "name" => event.name,
                  "path" => event.watcher.path,
                  "created_at" => File.stat(pathname.to_s).ctime.to_f,
                  "contents" => File.read(pathname.to_s)
                )
              end
            end
          end
        end.run
      end
    end
  end
end
