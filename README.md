# kdbslack
A framework for a KDB back end to a Slack bot

kdbslack is a plugin-based framework for interacting with Slack from KDB. Functionality is added to the framework by way of three types of plugins; [auto](#auto-plugins), [command](#command-plugins) & [event](#event-plugins). In addition, there is "worker" functionality that can be leveraged by plugins.

## Starting kdbslack

In order to start kdbslack, clone this repo & run `q kdbslack.q` from the root directory of this repo. (You will also need to update some config files). There are a number of command line options you can/should specify when running also:

* `-load` - list of directories to load with kdbslack e.g. `-load auto command` to load all plugins
* `-post` - define handler for HTTP POST queries, required for command & event plugins
* `-timer` - enable timer, required for auto plugins

For example, to start with full functionality on port 8100:

```
$ q kdbslack.q -p 8100 -load auto command -post -timer
```

To start with only auto plugins (will automatically select a free port to run on & log this to console):

```
$ q kdbslack.q -load auto -timer
```

## Plugins

### auto plugins

Auto plugins are timer based and are run periodically. These plugins are perfect for polling Web APIs on a given frequency, or running a periodic status report, for example.

Several examples of these are included, such as `feeds.q` which checks for new KDB+ related questions on public forums such as Google Groups & StackOverflow. Another included example is `hub.q` which checks for newly completed challenges & newly earnt badges on the [AquaQ Challenge Hub](http://challenges.aquaq.co.uk/).

These plugins (along with several other examples) are located within the `auto/` directory. In order to write an auto plugin, the only real requirement is to register with the timer, via `.timer.add` or `.timer.adddaily` functions, for example:

```rust
.timer.add[`.chlg.tm;`;00:05;1b]                    //call .chlg.tm function with null arg every 5 mins, repeat
.timer.adddaily[`.status.tm;`;09:00;"2-6"]          //call .status.tm function with null arg at 9am, Monday-Friday (i.e. where date mod 7 is in 2-6)
```
When starting kdbslack, use the `-load auto` command line arg to load the `auto/` directory and all plugins located there.

### command plugins

Command plugins respond to [slash commands](https://api.slack.com/slash-commands) in Slack.

Several examples are included, such as `hub.q` which provides functionality for querying the leaderboard from the [AquaQ Challenge Hub](http://challenges.aquaq.co.uk/).

Such examples are located within the `command/` directory. To write a command plugin, you must write a function that accepts a dictionary (with command parameters in ``x[`text]``, and other information such as user & channel included in dictionary), and then register this in the `.cmd` namespace with the function name the same as the slash command. For example:

```rust
.cmd.hub:.hub.f                                   //register .hub.f as the handler function for the /hub command
```

When starting kdbslack, include `command` in the load directories to load these plugins. You must also specify `-post` on the command line to define the HTTP POST request handler, as slash commands are sent by Slack as POST requests. Owing to this, you will most likely also want to specify a port to run on, and this will need to be one that is publicly accessible.

### event plugins

Event plugins respond to [events](#https://api.slack.com/events-api) from Slack e.g. a new team member joining Slack.

Currently the only example implemented of this is for a team member joining, the `team_join` event. This example is currently located in `util/slack.q` although in future this will be moved to it's own directory similar to auto & command.

An event handler function should accept a dictionary, similar to a command handler. In order to register a handler function, it should be placed in the `.slack.events` dictionary, for example:

```rust
\d .slack
events.team_join:{[e]
  if[not e[`user][`id] in .slack.userlist`id;                                       //check if this is a dupe notification etc.
     .slack.userlist,:"*SS"$`id`name`real_name#e`user;                              //add to user list so we don't welcome them twice
     .lg.o "Sending welcome msg to new user ",e[`user][`real_name]," (",e[`user][`name],")";
     postas[welcomemsg;e[`user][`id];"AquaQ Analytics Welcome"];                    //send welcome message as DM (via slackbot conversation)
    ];
 }
 ```
 
 Due to their location in `util/slack.q`, currently all event plugins will always be loaded. However for them to work, you will need to use the `-post` option on the command line & specify a publicly accessible port that is also configured on Slack.

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

