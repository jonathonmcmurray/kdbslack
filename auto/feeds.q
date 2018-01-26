\d .feeds

.util.loaddir`:auto/feeds

.feeds.cfg:update id:i from ("S**";enlist",")0:`:config/feeds.csv   //load feeds config
.feeds.ldt:.feeds.cfg[`id]!count[.feeds.cfg]#.z.z                   //set last dt for each feed to current dt

col:{[x;y] "\033[",string[x],"m",y,"\033[0m"}                       //generic colouring function
link.col:col[35]                                                    //colour links (purple)
title.col:col[33]                                                   //colour titles (yellow)

fmt0:{[c;t;m;n]                                                     //format a single message; c-colour flag,t-feed type,m-message,n-feed name
  u:user[t]m;                                                       //extract username using type-specific user func
  l:$[c;link.col;::]link[t]m`link;                                  //extract link using type-specific link func, optionally colour
  t:$[c;title.col;::]title[t]m`title;                               //extract title using type-specific title func, optionally colour
  u," asked a question on ",n," titled: ",t,"\nLink: ",l            //put together string for message, include feed name n
 }

fmt:{fmt0[0b;x;;z] each y}                                          //projection to format a list of messages, no colour
fmtc:{fmt0[1b;x;;z] each y}                                         //projection to format a list of messages, with colour

.feeds.tm:{[cfg]                                                    //timer function for feeds checking
  nq:chk'[cfg`type;cfg`id;] dl'[cfg`type;cfg`url];                  //download & check each feed in cfg
  if[0<max count@'nq;                                               //check for 0 being less than count of nq - FIX this check is wrong
    .lg.a "New questions in feeds, sending to slack";
    .slack.msg[.slack.channels`publicq]@'raze fmt'[cfg`type;nq;cfg`name]                     //format new messages without colour & send to slack
    ];
 }

\d .

.timer.add[`.feeds.tm;enlist .feeds.cfg;00:05:00;1b]
