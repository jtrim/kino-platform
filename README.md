# Notifier Application
Read kino-ssh-server/README.md first, then run:

```sh
docker-compose run notifier bash -c "bin/console"
```

# Web App

``` sh
$ cd kino_webapp
$ mix ecto.create
$ mix phoenix.server
```


TODO:

- [X] Write a small wrapper client around Bunny
- [X] Add Statsd collection to the rabbitmq client
- [X] Get an ssh server running in a docker container
- [X] Wire everything up with docker-compose
- [ ] Modify the rabbitmq client to wrap / unwrap message payloads in json for producing / consuming
  - [X] Wrap in json
  - [ ] Unwrap json
    - Note: was thinking about assuming the payload is json, then handling
      decoding errors by dropping a log message and returning the raw body
- [ ] Write a file-system watcher that submits rabbitmq messages when files change
  - Messages should include the username, created timestamp, operation, source / destination (in the case of moves) and the file contents (in the case of everything but deletion)
  - Note: wrote a quick and dirty version of this to watch for files created
    just to prove the concept. Need to go through `man inotify` and create
    appropriate watchers for event types that make sense
- [ ] Once the concept is proven, go write unit tests / refactor
- [ ] Figure out directory permissions that make sense to prevent moving of the
  user's own home directory and draft / published folders
- [ ] Design a default shell application so users can run something like "ssh user@kino draft foo.txt"
