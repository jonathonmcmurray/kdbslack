\d .aoc

.req.addcookie["adventofcode.com";"session=",first read0`:config/aoc_cookie];                                   //load & add AoC session cookie
st:enlist[0N 0N]!enlist[flip `name`local_score`stars`global_score`id`last_star_ts`completion_day_level!()];     //state dict for states of each lb & year combo
yrlst:2015 2016 2017 2018;                                                                                           //list of years that can be queried
prstrs:enlist[0N]!enlist ([id:()] stars:());                                                                    //dict to mantain prev star totals
lb:113948                                                                                                       //AquaQ leaderboard

getlb:{[x;y] /x:leaderboard id,y:year
  j:.req.g"http://adventofcode.com/",string[y],"/leaderboard/private/view/",string[x],".json";                  // web request for lb JSON
  t:`name`local_score`stars`global_score`id`last_star_ts`completion_day_level#/:value j`members;                
  :update name:("anon",/:id) from t where 10h<>type each name;
 };

updst:{[x;y] /x:leaderboard id,y:year
  st[(x;y)]:getlb[x;y];
 };

totstrs:{[x] /x:leaderboard
  :update "j"$stars from 1!select id,name,stars from st@(x;last yrlst);
 };

newstrs:{[x] /x:leaderboard
  updst[lb;last yrlst];                                                                                         //update state for all years on all boards
  u:(where not prstrs[lb]~'totstrs lb);
  u:(exec id from u) inter exec id from totstrs lb where stars>0;
  if[count u;                                                                                                   //alert
     s:"The following users have received stars in the last 10 mins:\n```",
        .Q.s[select from (totstrs[lb]-prstrs[lb]) where id in u],"```";
     .slack.postase[s;.slack.chanlist"advent";"Advent Bot";":star:"];
     prstrs[.aoc.lb]:totstrs .aoc.lb;                                                                           //update state of prev stars
    ];
 };

gtlb:{[x;y] /x:leaderboard id,y:year
  t:select `$name,stars,local_score,global_score from (update `$id from .aoc.st[(x;y)]) where stars>0,not null id;
  :$[`;("User";"Stars";"Local Score";"Global Score")] xcol `local_score`stars xdesc t;
 };

aclb:{[u;c] /u:user,c:channel
  updst[.aoc.lb;last .aoc.yrlst];
  .slack.postase["Hey ",u," here's the current AOC leaderboard for this year:\n```",.Q.s[gtlb[.aoc.lb;last .aoc.yrlst]],"```";
          c;"Advent Bot";":star:"];
 };

\d .

/.aoc.updst[.aoc.lb;last .aoc.yrlst];                                                                            //update state dict for both leaderboards across all three years
/@[`.aoc.prstrs;.aoc.lb;:;.aoc.totstrs .aoc.lb];                                                                 //get the initial no. of stars for each user
/`cron insert (.z.P+"u"$10;`.aoc.newstrs;enlist .aoc.lbs`openaccess);        //insert cron job to update & detect new stars every 10 mins
