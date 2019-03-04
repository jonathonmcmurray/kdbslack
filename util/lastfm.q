(.lfm.console:{system"c "," "sv string 20 1000|system"c"})[];

/ libs
\l util/req.q
\l util/log.q

/ config
.lfm.enabled:1b;                                                                                / determine if functionality is enabled
.lfm.file.key:`:config/lfm_key;                                                                 / location of API key file
.lfm.file.cache:`:config/lfm_users;                                                             / location of user cache file
.lfm.channel:`music;                                                                            / channel to post charts to
.lfm.url:"http://ws.audioscrobbler.com/2.0/?";                                                  / base of URL
.lfm.o.default:10;                                                                              / default number to include for charts
.lfm.o.custom:`tracks`artists`albums!10 5 5;                                                    / custom number of results to include for each chart type
.lfm.o.charts:`tracks`albums`artists;                                                           / list of charts to return
.lfm.o.users:0b;                                                                                / whether to include users in chart output

/ preamble
.lfm.key:@[{first read0 x};.lfm.file.key;""];                                                   / get api key
.lfm.users:@[get;.lfm.file.cache;([uid:()]name:();username:())];                                / get user cache
.lfm.users:([uid:0 1 2]name:`Thomas`Scott`Conal;username:`rocketship92`squigley93`clogan38);    / user cache for testing
.lfm.valid:{.lfm.enabled and not""~.lfm.key};                                                   / check service is enabled and key file exists

/ http requests
.lfm.req.r:{[d]                                                                                 / [params] make a request to last.fm
  url:.lfm.url,.req.urlencode d;                                                                / encode passed params
  :.j.k raze system"curl -s '",url,"'";
 };

.lfm.req.s:{[d].lfm.req.r(`format`api_key!(`json;.lfm.key)),d};                                 / [params] make a request for a single page

.lfm.req.p:{[d]                                                                                 / [params] make a paginated request to last.fm
  d:(`format`api_key`limit`page!(`json;.lfm.key;1000;1)),d;
  d[`limit]:1000&l:d`limit;                                                                     / set limit for results per page
  :first({[t;d;l]                                                                               / [table;params;limit]
    r:.lfm.req.r d;                                                                             / make request
    if[`error in key r;
      .lg.e"Error making last.fm request";
      :(([]playcount:();artist:();name:();album:());d;0);
    ];
    l&:"J"$first[value r][`$"@attr"]`total;                                                     / update limit to ensure correct number of results are processed
    r@:first except[;`$"@attr"]key r@:first key r;                                              / extract relevant values
    :(t,r;@[d;`page;1+];l);                                                                     / return params
  }.)/[{x[2]>count x 0};(();d;l)];
 };

.lfm.r.tracks:{[u].lfm.req.p`method`period`user`limit!(`user.gettoptracks;`7day;u;0W)};         / [username] helper function for top track requests
.lfm.r.albums:{[u].lfm.req.p`method`period`user`limit!(`user.gettopalbums;`7day;u;0W)};         / [username] helper function for top album requests
.lfm.r.artists:{[u].lfm.req.p`method`period`user`limit!(`user.gettopartists;`7day;u;0W)};       / [username] helper function for artist requests

.lfm.user.top.tracks:{[u]                                                                       / [user] top tracks for a user
  res:.lfm.r[`tracks]u;                                                                         / request top tracks
  res:`playcount`artist`name#res;                                                               / extract playcount table
  :`playcount`artist`track xcol .lfm.parse[res;cols res];                                       / extract data from nested columns
 };

.lfm.user.top.albums:{[u]                                                                       / [user] top albums for a user
  res:.lfm.r[`albums]u;                                                                         / request top albums
  res:`playcount`artist`name#res;                                                               / extract playcount table
  :`playcount`artist`album xcol .lfm.parse[res;cols res];                                       / extract data from nested columns
 };

.lfm.user.top.artists:{[u]                                                                      / [user] top artists for a user
  res:.lfm.r[`artists]u;                                                                        / request top artists
  res:`playcount`name#res;                                                                      / extract playcount table
  :`playcount`artist xcol@[;`name;`$].lfm.parse[res;cols res];                                  / extract data from nested columns
 };

.lfm.h.top:{[t;n;u]                                                                             / [type;name;username] wrapper to get chart for single user
  .lg.o"Requesting ",string[t]," data for ",string n;
  res:update user:n from .lfm.user.top[t]u;                                                     / make request to last.fm
  .lg.o"Returning ",string[t]," data for ",string n;
  :res;
 };

.lfm.top:{[t]                                                                                   / get chart for passed type
  .lg.o"Requesting top ",string[t]," for each user";
  res:raze .lfm.h.top[t]./:exec(name,'username)from .lfm.users;                                 / get top chart for passed param for each user
  .lg.o"Returning top ",string[t]," for each user";
  :res;
 };

/ chart formatting functions
.lfm.c.tracks:{[data]select sum playcount,users:distinct user by artist,`$track from data};     / select data for tracks chart
.lfm.c.albums:{[data]select sum playcount,users:distinct user by artist,`$album from data};     / select data for albums chart
.lfm.c.artists:{[data]select sum playcount,users:distinct user by artist from data};            / select data for artists chart

.lfm.c.wrapper:{[t;data]                                                                        / [type;data] wrapper for selecting chart data
  c:.lfm.o.default^.lfm.o.custom t;                                                             / find number of results to return
  res:`n xcols 0!update n:1+i from c#`playcount xdesc .lfm.c[t]data;                            / sort by playcount and add numbering
  .lg.o"Returning ",string[t]," chart";
  :$[.lfm.o.users;res;delete users from res];                                                   / return table, removing users column if required
 };

.lfm.c.format:{[t;data]t," Chart\n\n",.Q.s .lfm.h.trim data};                                   / [type;data] format chart for slack

.lfm.h.trim:{[data]                                                                             / [data] trim columns
  d:(cols[data]inter key d)#d:`artist`track`album!30 50 40;                                     / custom column widths
  :{@[x;y;{`$x sublist string y}[z]@']}/[data;key d;value d];                                   / trim columns
 };

/ output formatting functions
.lfm.o.format:{[t].lfm.c.format[@[string t;0;upper]].lfm.c.wrapper[t].lfm.top[t][]};            / wrapper for formatting charts

.lfm.chart:{
  if[0=count .lfm.o.charts;                                                                     / check that there are charts to produce
    .lg.w"No chart types specified in config, .lfm.o.charts is unpopulated";
    :();
  ];
  .lg.o"Producing charts for ",", "sv string .lfm.o.charts;
  res:"\n\n"sv{.lfm.o.format[x][]}'[(),.lfm.o.charts];                                          / get top charts for passed params and stitch together
  uc:"\n\nUser count: ",string count .lfm.users;                                                / get user stats
  .lg.o"Returning formatted charts";
  :"```",res,uc,"```";                                                                          / wrap in code block to preserve formatting in slack
 };

/ helper functions to correctly parse columns
.lfm.parse:{[t;c]{.lfm.p[y]x}/[t;c]};                                                           / [table;columns] format columns
.lfm.p.artist:{@[x;`artist;{`$x`name}@']};                                                      / extract name from nested table
.lfm.p.playcount:{@[x;`playcount;"J"$]};                                                        / convert to long

/ user handling
.lfm.u.handler:{[id;n;u]                                                                        / [id;name;username] handle username update requests
  st:.lfm.u[`rm`add 0<count u][id;n;u];                                                         / update usernames in memory
  .lfm.file.cache set .lfm.users;                                                               / update usernames on disk
  :st;                                                                                          / return request status
 };

.lfm.u.add:{[id;n;u]                                                                            / [id;name;username] add user to cache
  .lg.o"Updating username for ",n;
  if[(`$u)in exec username from .lfm.users;                                                     / check for username duplication
    .lg.w"User ",n," is attempting to add username ",u," that is already in use";
    :(0b;"username already in use");                                                            / return failed status
  ];
  if[`error in key v:.lfm.req.s`method`user!("user.getinfo";u);                                 / verify that valid last.fm username has been passed
    .lg.e"Failed to get user info for ",u," with error: ",v`message;
    :(0b;"username is invalid");                                                                / return failed status
  ];
  `.lfm.users upsert(id;`$n;`$u);                                                               / add/update record in cache
  :(1b;"successfully added username ",u);                                                       / return passed status
 };

.lfm.u.rm:{[id;n;u]                                                                             / [id;name;username] remove user from cache
  .lg.o"Removing username for ",n;
  delete from`.lfm.users where uid=id;                                                          / remove record in cache
  :(1b;"successfully removed last.fm username");                                                / return passed status
 };
