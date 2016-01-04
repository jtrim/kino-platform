require "test_helper"

module Kino
  module Notifier
    class FileObserverTest < Minitest::Test
      def setup
        @messaging_client = TestMessagingClient.new
        @tmp_observation_root = Pathname.new("/").join("tmp", "kino-notifier", File.basename(__FILE__))
        FileUtils.mkdir_p(@tmp_observation_root)
      end

      def teardown
        tear_down_observer
        clean_up_sandbox
      end

      def test_file_created_publishes_no_messages
        start_observer_process

        with_retry do
          assert_empty @messaging_client.payloads
        end
      end

      # --- file_created

      def test_file_created_publishes_messages
        start_observer_process_but_before do
          setup_user_dir("testuser")
        end

        write("contents!", "testuser", "foo.txt")

        with_retry do
          assert_equal 1, @messaging_client.payloads["file_created"].size
        end
      end

      def test_file_created_publishes_messages_for_multiple_files
        start_observer_process_but_before do
          setup_user_dir("testuser")
        end

        write("contents!", "testuser", "foo.txt")
        write("other contents!", "testuser", "foo1.txt")

        with_retry do
          assert_equal 2, @messaging_client.payloads["file_created"].size
        end
      end

      def test_file_created_publishes_messages_for_multiple_users
        start_observer_process_but_before do
          setup_user_dir("testuser")
          setup_user_dir("otheruser")
        end

        write("contents!", "testuser", "foo.txt")
        write("contents!", "otheruser", "foo.txt")

        with_retry do
          assert_equal 2, @messaging_client.payloads["file_created"].size
        end
      end

      def test_file_created_publishes_only_one_message_per_file
        start_observer_process_but_before do
          setup_user_dir("testuser")
        end

        write("contents!", "testuser", "foo.txt")
        write("different contents!", "testuser", "foo.txt")

        with_retry do
          assert_equal 1, @messaging_client.payloads["file_created"].size
        end
      end

      def test_file_created_publishes_messages_for_expected_file_types
        start_observer_process_but_before do
          setup_user_dir("testuser")
        end

        write("contents!", "testuser", "foo.txt")
        write("contents!", "testuser", "foo.md")
        write("contents!", "testuser", "foo.nope")

        with_retry do
          assert_equal 2, @messaging_client.payloads.fetch("file_created", []).size
        end
      end

      # --- file_modified

      def test_file_modified_publishes_no_messages
        start_observer_process

        with_retry do
          assert_empty @messaging_client.payloads
        end
      end

      def test_file_modified_publishes_messages
        start_observer_process_but_before do
          setup_user_dir("testuser")
          write("contents!", "testuser", "foo.txt")
        end

        write("more contents!", "testuser", "foo.txt")

        with_retry do
          assert_equal 1, @messaging_client.payloads.fetch("file_modified", []).size
        end
      end

      def test_file_modified_publishes_messages_for_multiple_files
        start_observer_process_but_before do
          setup_user_dir("testuser")
          write("contents!", "testuser", "foo.txt")
          write("other contents!", "testuser", "foo1.txt")
        end

        write("more contents!", "testuser", "foo.txt")
        write("more other contents!", "testuser", "foo1.txt")

        with_retry do
          assert_equal 2, @messaging_client.payloads["file_modified"].size
        end
      end

      def test_file_modified_publishes_messages_for_multiple_users
        start_observer_process_but_before do
          setup_user_dir("testuser")
          setup_user_dir("otheruser")

          write("contents!", "testuser", "foo.txt")
          write("contents!", "otheruser", "foo.txt")
        end

        write("more contents!", "testuser", "foo.txt")
        write("more contents!", "otheruser", "foo.txt")

        with_retry do
          assert_equal 2, @messaging_client.payloads["file_modified"].size
        end
      end

      def test_file_modified_publishes_messages_for_expected_file_types
        start_observer_process_but_before do
          setup_user_dir("testuser")
          write("contents!", "testuser", "foo.txt")
          write("contents!", "testuser", "foo.md")
          write("contents!", "testuser", "foo.nope")
        end

        write("more contents!", "testuser", "foo.txt")
        write("more contents!", "testuser", "foo.md")
        write("more contents!", "testuser", "foo.nope")

        with_retry do
          assert_equal 2, @messaging_client.payloads.fetch("file_modified", []).size
        end
      end

      private

      def write(contents, *paths)
        IO.write(@tmp_observation_root.join(*paths).to_s, contents)
        sleep 0.2 # give inotify time to register changes
      end

      def setup_user_dir(dir)
        FileUtils.mkdir_p(@tmp_observation_root.join(dir))
      end

      def start_observer_process
        yield if block_given?

        @thread = Thread.new do
          FileObserver.new(@tmp_observation_root.to_s, @messaging_client).observe
        end

        sleep 0.5 # give inotify time to set up watchers
      end
      alias :start_observer_process_but_before :start_observer_process

      def with_retry
        tries = 0
        begin
          yield
        rescue
          if (tries += 1) >= 3
            raise
          else
            sleep 0.2
            retry
          end
        end
      end

      def clean_up_sandbox
        FileUtils.rm_rf(@tmp_observation_root)
      end

      def tear_down_observer
        Thread.kill(@thread) if @thread
      end
    end
  end
end
