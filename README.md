# nostr voliere

The idea here is to provide a simple relay implementation written in readable Ruby.

```sh
bundle install
bin/check
bundle exec falcon serve --port 3000 --count 1
```

## Design considerations

The first trial only uses files and unix commands for the event log.
`grep` is very fast in searching unindexed big files.
This proved to be an interesting but difficult idea because of three obstacles:

* Blocking IO to await incoming events (solved with forking on each request, how slow is forking today even?)
* Multiple filters (workaround using [`pee`](https://linux.die.net/man/1/pee) from _moreutils_.
* Filtering for date ranges is difficult with `grep`.

**Other thoughts:**

* Events in the event log are approximately sorted by `created_at`. This solution cannot take advantage of this.
* I also thought about creating named pipes using `mkfifo` but they block on write rather than before read.
* One thing I discovered was that ordered nostr event JSON [cannot be assumed](https://github.com/nostr-protocol/nips/discussions/1002).

## Next trial

Tear down the files and unix approach and replace it with a full Ruby file reading solution.
Should be fast enough at least with filters containing a lot of critera.
Can also do binary search on date-ordered event log.

## Other ideas

* I'd like to try the LISTEN NOTIFY approach of SQLite. Sadly the Ruby drivers don't support it (yet). Rust SDK does.
* Go fullly Postgres (since this project could be used as a Rails sidecar and there's Postgres anyways)

## License

Copyright 2023-2024 by Josua Schmid published under the MIT license
