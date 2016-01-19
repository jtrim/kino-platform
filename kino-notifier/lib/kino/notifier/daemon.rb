module Kino
  module Notifier
    class Daemon
      def initialize(logger = Logger.new($stdout))
        @users = {}
        @stale_observer_threads = []
        @semaphore = Mutex.new
        @logger = logger
      end

      def start(username)
        @logger.info("Starting observer for #{username}")
        stop(username)
        @semaphore.synchronize do
          @users[username] = Thread.new do
            FileObserver.new("/home/#{username}").observe
          end
        end
      end

      def stop(username)
        if (thread = @users[username])
          @logger.info("Stopping existing observer for #{username}")
          @semaphore.synchronize do
            @stale_observer_threads << [thread, Time.now.to_i + 10]
            @users[username] = nil
          end
        end
      end

      def run
        Dir["/home/*"].each do |userdir|
          start(File.basename(userdir))
        end

        @stale_observer_killer = Thread.new do
          loop do
            @stale_observer_threads.
              select{|(thread, kill_after)| thread.alive? && (Time.at(kill_after) <= Time.now)}.
              each do |(thread, kill_after)|
                @logger.info "Killing stale observer thread for #{thread.inspect}. " \
                             "now=#{Time.now.to_i}, after=#{kill_after}"
                thread.kill
              end
            @semaphore.synchronize do
              @stale_observer_threads.delete_if do |(thread, kill_after)|
                (!thread.alive?).tap do |is_disposable|
                  if is_disposable
                    @logger.info "Disposing of dead observer thread for #{thread.inspect}. " \
                                 "now=#{Time.now.to_i}, after=#{kill_after}"
                  end
                end
              end
            end
            sleep 3
          end
        end

        # Will block
        Kino::Notifier::MessagingClient.new.consume("file_created") do |message_body|
          payload  = Oj.load(message_body)
          username = Pathname.new(payload["path"]).split.last.to_s
          start(username)
        end
      end
    end
  end
end
