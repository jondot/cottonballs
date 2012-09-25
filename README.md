# Cottonballs
Cottonballse is your own mock, fluffy version of GCM for testing
purposes, based on [node.js](http://nodejs.org).

You would need this if you keep asking yourself the question 

> How can
I test sending **tons** of GCM messages, without really bothering Google?

With Cottonballs, you don't need to trouble yourself about
large-scale testing against real GCM, abusing the GCM service for testing, or
needlessly expiring quotas when you're developing your Push solutions.

## Quick Start

You'll have to do *some* work here.

```
$ git clone git://github.com/jondot/cottonballs.git
$ cd cottonballs
$ npm install
$ ./genkeys.sh
$ [sudo] node cottonballs [options]
```

Aside from getting Cottonballs, you generated SSL keys with `genkeys.sh`
and you also might want to use `sudo` to run the service to allow the
service to bind on SSL.

### SSL?

By default, Cottonballs will try to bind on SSL. The fastest possible
way to use it is to
run Cottonballs, and change your `/etc/hosts` to point to it, instead of
`android.googleapis.com`.

```
# /etc/hosts
127.0.0.1 android.googleapis.com
```

This is a _very bad_ thing to do generally, but depending on the point of view,
can be very good (think of pre-configuring a test machine with this, and
deploying and testing on it - no configuration or code changes on your
side).

In any case, Cottonballs also binds to a non-SSL port just in case _you do_
want to point your code at it directly.

## Behaviour

You can configure Cottonballs to behave in very useful ways,
through command-line options:

* `-f` or `--failure-ratio` will simulate message send failures.
* `-l` or `--latency` will simulate a _processing latency_. So that you
can simulate cases where GCM isn't behaving that well in terms of
performance.
* `-x` or `--latency-flux` is the variance in latency.
* `-c` or `--crash-ratio` is the of all requests that will crash on you
(HTTP 500 from GCM).
* `-p` or `--port` is a non-SSL port to bind on


## Tinkering

That's it. Some of the options (such as certificate filenames) are
hard coded, and this is designed to minimize any friction and get you going as fast as
possible. 

The code is _very_ hackable and you're welcome to submit
pull requests if you think it'd be suitable.

When in doubt just run `node cottonballs` to get a listing of your
options.






# Contributing

Fork, implement, add tests, pull request, get my everlasting thanks and a respectable place here :).


# Copyright

Copyright (c) 2012 [Dotan Nahum](http://gplus.to/dotan) [@jondot](http://twitter.com/jondot). See MIT-LICENSE for further details.
