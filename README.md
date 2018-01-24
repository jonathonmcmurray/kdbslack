# kdbslack
A framework for a KDB back end to a Slack bot

## auto.q

This script forms the backend for the "automatic" messaging portion of the bot.

These are driven by a timer (`util/timer.q`) and use Slack webhooks to send
messages to specific Slack channels.

The following files are loaded and used in this process:

```
.
├── auto
│   ├── feeds
│   │   ├── ggrp.q
│   │   └── stack.q
│   ├── feeds.q
│   ├── shame.q
│   └── status.q
├── auto.q
```

* feeds.q provides notifications on new StackOverflow & Google Groups questions
* shame.q provides notificatons of high memory usage
* status.q provides a daily report on the status of the host server

## command.q

This script provides the backend for the "command" portion of the bot.

This allows the creation of functions that can be called from Slack channels.
This script must be run on an externally accessible server, and accepts
HTTP POST requests, determining the local function to run in response.

## config/

* channels.csv lists webhooks for specific channels [not on repo]
* feeds.csv lists feeds for feeds.q to parse & notify on
* wiki.csv contains kx wiki links for kdb keywords, used by command.q

## util/

* log.q provides logging functions
* slack.q loads channels config & provides messaging function
* timer.q provides a simple timer functionality, allowing multiple jobs on multiple schedules
* worker.q provides functionality for running a script in the background and returning the result (see below)
* xml2json.py is used by feeds.q for parsing RSS feeds (Google Groups)

## workers/

Workers are scripts designed to be run in the background by the `auto.q` process.

For example, status.q builds a status report on the current host - this occurs in a background 
process so as to not hang the main process. The finished report is returned to the main process
via a callback function passed to the background script as a command line arg.

An example of the usage of workers is shown below:

```
q)-1 read0`:util/dummy_worker.q;
\l util/worker.q
system"sleep 10";
.worker.ret[1+1];
q).work.cb:{0N!x}
q).worker.create["util/dummy_worker.q";`.work.cb]
q)
q)
q)/not hung
q)2 /value returned from worker
```

For another example, see `auto/status.q` and it's companion `workers/status.q`

