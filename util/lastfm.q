(.lfm.console:{system"c "," "sv string 20 1000|system"c"})[];

/ config
.lfm.enabled:1b;                                                                                / determine if functionality is enabled
.lfm.file.key:`:config/lfm_key;                                                                 / location of API key file
.lfm.file.cache:`:config/lfm_users;                                                             / location of user cache file
.lfm.channel:"qradio";                                                                          / channel to post charts to
.lfm.url:"http://ws.audioscrobbler.com/2.0/?";                                                  / base of URL
.lfm.o.default:10;                                                                              / default number to include for charts
.lfm.o.custom:`tracks`artists`albums`stats!20 20 10 20;                                         / custom number of results to include for each chart type
.lfm.o.charts:`tracks`artists`albums`stats;                                                     / list of charts to return
.lfm.o.cols:`users`usercount!01b;                                                               / optional columns to include in output
.lfm.o.outputChart:1b;                                                                          / determine if chart output should be saved to disk
.lfm.o.output:hsym@[get;`.lfm.o.output;`:/home/shared/lastfm];                                  / directory to save chart output

/ preamble
.lfm.key:@[{first read0 x};.lfm.file.key;""];                                                   / get api key
.lfm.users:@[get;.lfm.file.cache;([uid:()]name:();username:())];                                / get user cache
.lfm.valid:{.lfm.enabled and not""~.lfm.key};                                                   / check service is enabled and key file exists

.lfm.req.cols:enlist[`recent]!enlist`artist`name`album;                                         / columns to include in output

.lfm.unix:{floor((`long$`timestamp$x)-`long$1970.01.01D00:00)%1e9};                             / [date/timestamp] convert to unix timestamp

/ http requests
.lfm.req.r:{[d]                                                                                 / [params] make a request to last.fm
  url:.lfm.url,.url.enc d;                                                                			/ encode passed params
  :.j.k raze system"curl -s '",url,"'";                                                         / make curl request to last.fm servers
 };

.lfm.req.s:{[d].lfm.req.r(`format`api_key!(`json;.lfm.key)),d};                                 / [params] make a request for a single page

.lfm.req.p:{[d]                                                                                 / [params] make a paginated request to last.fm
  d:(`format`api_key`limit`page!(`json;.lfm.key;1000;1)),d;
  d[`limit]:1000&l:d`limit;                                                                     / set limit for results per page
  :first({[t;d;l]                                                                               / [table;params;limit]
    r:.lfm.req.r d;                                                                             / make request
    if[`error in key r;
      .lg.e"Error making last.fm request, error code ",string r`error;
      if[r[`error]in 8 29f;                                                                     / if backend fails (8) or rate limit exceeded (29) then sleep and retry
        .lg.o"Sleeping for 60s before retrying";
        system"sleep 60";
        :(t;d;l);
      ];
      :(t;d;0);
    ];
    if[0=l&:"J"$first[value r][`$"@attr"]`total;                                                / update limit to ensure correct number of results are processed
      .lg.o"No results for user";
      :(t;d;0);
    ];
    r@:first except[;`$"@attr"]key r@:first key r;                                              / extract relevant values
    r@:where not(`$"@attr")in/:key each r;                                                      / filter out now playing duplicates
    :(t,r;@[d;`page;1+];l);                                                                     / return params
  }.)/[{x[2]>count x 0};(();d;l)];
 };

.lfm.r.recent:{[u;s;e].lfm.req.p`method`user`limit`from`to!(`user.getrecenttracks;u;0W),.lfm.unix s,e}; / [username;start timestamp;end timestamp] get scrobbled tracks in specified window

.lfm.user.recent:{[u;s;e]                                                                       / [user;start timsetamp;end timestamp]
  res:flip[cl!()],(cl:.lfm.req.cols`recent)#/:.lfm.r.recent[u;s;e];                             / request top artists
  :`artist`track`album xcol@[;`name;`$].lfm.parse[res;cols res];                                / extract data from nested columns
 };

.lfm.h.scrobbles:{[s;e;n;u]                                                                     / [start timestamp;end timestamp;name;username] get scrobbles for a single user
  .lg.o"Requesting scrobbles for ",p:string[u]," between ",string[s]," and ",string e;
  res:update user:n from .lfm.user.recent[u;s;e];                                               / get scrobbles and add name to table
  .lg.o"Returning scrobbles for ",p;
  :res;                                                                                         / return scrobbles for a user
 };

.lfm.scrobbles:{[s;e]                                                                           / [start timestamp;end timestamp] get scrobbles for all users
  .lg.o"Requesting scrobbles for each user between ",string[s]," and ",string e;
  u:`$exec id from .slack.userlist;                                                             / get list of user ids from slack
  res:raze .lfm.h.scrobbles[s;e]./:exec(name,'username)from .lfm.users where uid in u;          / get top chart for passed param for each valid user
  .lg.o"Returning top scrobbles for each user between ",string[s]," and ",string e;
  :res;                                                                                         / return raw data
 };

/ chart formatting functions
.lfm.c.tracks:{[data]select scrobbles:count i,users:distinct user,usercount:count distinct user by artist,track from data}; / select data for tracks chart
.lfm.c.albums:{[data]select scrobbles:count i,users:distinct user,usercount:count distinct user by artist,album from data}; / select data for albums chart
.lfm.c.artists:{[data]select scrobbles:count i,users:distinct user,usercount:count distinct user by artist from data}; / select data for artists chart

.lfm.c.wrapper:{[s;e;t;data]                                                                    / [start timestamp;end timestamp;type;data] wrapper for selecting chart data
  f:$[t in 1_key .lfm.s;t;`default];                                                            / determine aggregation funtion, allowing for custom logic
  cht:(.lfm.s f)[s;e;t;data];                                                                   / aggregate data
  .lfm.save[s;e;t;cht];                                                                         / save chart to disk (if enabled)
  .lg.o"Returning ",string[t]," chart";
  :(.lfm.o.default^.lfm.o.custom t)sublist cht;                                                 / return chart
 };

.lfm.s.default:{[s;e;t;data]
  res:`scrobbles`usercount xdesc .lfm.c[t]data;                                                 / sort by scrobbles and total listening users
  res:`n xcols 0!update n:fills?[differ scrobbles;1+i;0N]from res;                              / number track placement
  :where[not .lfm.o.cols]_res;                                                                  / apply optional column settings
 };

.lfm.s.stats:{[s;e;t;data]                                                                      / [start timestamp;end timestamp;data] generate statistics from raw chart data
  u:`$exec id from .slack.userlist;                                                             / get list of user ids from slack
  sts:([]stat:();size:());
  sts,:(`$"Registered users";count .lfm.users);                                                 / count number of valid users
  sts,:(`$"Valid users";count select from .lfm.users where uid in u);                           / count number of valid users
  sts,:(`$"Unique scrobblers";count distinct data`user);                                        / get number of users to scrobble over charting period
  sts,:(`Scrobbles;count data);                                                                 / get total scrobbles over period
  sts,:(`Artists;count distinct data`artist);                                                   / get total scrobbles over period
  sts,:(`Albums;count distinct data`album);                                                     / get total scrobbles over period
  :sts;                                                                                         / return stats
 };

.lfm.c.format:{[t;data]t," Chart\n\n",.fmt.t .lfm.h.trim data};                                 / [type;data] format chart for slack

.lfm.h.trim:{[data]                                                                             / [data] trim columns
  d:(cols[data]inter key d)#d:`artist`track`album!30 50 40;                                     / custom column widths
  :{@[x;y;{`$x sublist string y}[z]@']}/[data;key d;value d];                                   / trim columns
 };

/ output formatting functions
.lfm.o.format:{[s;e;data;t].lfm.c.format[@[string t;0;upper]].lfm.c.wrapper[s;e;t]data};        / [start timestamp;end timestamp;data;type] wrapper for formatting charts

.lfm.chart:{[s;e]                                                                               / [start timestamp;end timestamp]
  if[0=count .lfm.o.charts;                                                                     / check that there are charts to produce
    .lg.w"No chart types specified in config, .lfm.o.charts is unpopulated";
    :();
  ];
  data:.lfm.scrobbles[s;e];                                                                     / get scrobbles for all users
  .lg.o"Producing charts for ",", "sv string .lfm.o.charts;
  fm:.lfm.o.charts!.lfm.o.format[s;e;data]'[.lfm.o.charts];                                     / get top charts for passed params
  .lg.o"Returning formatted charts and tables";
  :{"```",x,"```"}each fm;                                                                      / wrap in code block to preserve formatting in slack
 };

.lfm.save:{[s;e;t;c]                                                                            / [start timestamp;end timestamp;chart type;chart] save chart to disk
  if[not .lfm.o.outputChart;.lg.o"Saving to disk is disabled";:()];                             / exit early if saving not enabled
  .lg.o"Saving ",string[t]," chart to disk";
  fn:`$("_"sv enlist[string t],@'[;8;:;"_"](16 sublist/:string(s;e))except\:".:"),".csv";       / create filename for current chart
  (fp:` sv .lfm.o.output,fn)0:","0:@[c;exec c from meta[c]where t="s";string];                  / save chart to disk, converting symbols to string to preserve commas
  .lg.o"Finished saving ",string[t]," chart to ",1_string fp;
 };

/ helper functions to correctly parse columns
.lfm.parse:{[t;c]{.lfm.p[y]x}/[t;c]};                                                           / [table;columns] format columns
.lfm.p.artist:{@[x;`artist;{`$x`$"#text"}@']};                                                  / extract name from nested table
.lfm.p.album:{@[x;`album;{`$x`$"#text"}@']};                                                    / extract name from nested table

/ user handling
.lfm.u.handler:{[id;n;u]                                                                        / [id;name;username] handle username update requests
  st:.lfm.u[`rm`add 0<count u][id;n;u];                                                         / update usernames in memory
  .lfm.file.cache set .lfm.users;                                                               / update usernames on disk
  :st;                                                                                          / return request status
 };

.lfm.u.add:{[id;n;u]                                                                            / [id;name;username] add user to cache
  .lg.o"Updating last.fm username for ",n;
  if[(`$u)in exec username from .lfm.users;                                                     / check for username duplication
    .lg.w"User ",n," is attempting to add username ",u," that is already in use";
    :(0b;"username already in use");                                                            / return failed status
  ];
  if[`error in key v:.lfm.req.s`method`user!("user.getinfo";u);                                 / verify that valid last.fm username has been passed
    .lg.e"Failed to get last.fm user info for ",u," with error: ",v`message;
    :(0b;"username is invalid");                                                                / return failed status
  ];
  `.lfm.users upsert`$(id;n;u);                                                                 / add/update record in cache
  :(1b;"successfully added last.fm username ",u);                                               / return passed status
 };

.lfm.u.rm:{[id;n;u]                                                                             / [id;name;username] remove user from cache
  .lg.o"Removing username for ",n;
  delete from`.lfm.users where uid=`$id;                                                        / remove record in cache
  :(1b;"successfully removed last.fm username");                                                / return passed status
 };
