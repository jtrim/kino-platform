Read kino-ssh-server/README.md first, then run:

```sh
docker-compose run notifier bash -c "bin/console"
```

TODO:

- [X] Write a small wrapper client around Bunny
- [X] Add Statsd collection to the rabbitmq client
- [X] Get an ssh server running in a docker container
- [X] Wire everything up with docker-compose
- [ ] Modify the rabbitmq client to wrap / unwrap message payloads in json for producing / consuming
- [ ] Write a file-system watcher that submits rabbitmq messages when files change
  - Messages should include the username, created timestamp, operation, source / destination (in the case of moves) and the file contents (in the case of everything but deletion)
