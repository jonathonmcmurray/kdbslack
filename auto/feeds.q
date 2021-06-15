\d .feeds

.load.dir`:auto/feeds

.feeds.cfg:update id:i from ("S**";enlist",")0:`:config/feeds.csv                   //load feeds config
.feeds.ldt:.feeds.cfg[`id]!count[.feeds.cfg]#.z.z                                   //set last dt for each feed to current dt

ans:(exec name!id from .slack.userlist)`$"," vs' read0`:config/ansgroups.txt        //get list of answer groups
curgroup:0                                                                          //set the next group to get a notification to the first one

fmt0:{[t;m;n]                                                                       //format a single message; t-feed type,m-message,n-feed name
  u:user[t]m;                                                                       //extract username using type-specific user func
  l:link[t]m`link;                                                                  //extract link using type-specific link func, optionally colour
  t:title[t]m`title;                                                                //extract title using type-specific title func, optionally colour
  g:"\nAnswerers: <@",("> & <@" sv ans curgroup),">";                               //call out the group responsible for answering this question
  .feeds.curgroup:mod[curgroup+1;count ans];                                        //increment group counter
  u," asked a question on ",n," titled: ",t,"\nLink: ",l,g                          //put together string for message, include feed name n
 }
fmt:{fmt0[x;;z] each y}                                                             //projection to format a list of messages

.feeds.tm:{[cfg]                                                                    //timer function for feeds checking
  nq:chk'[cfg`type;cfg`id;] dl'[cfg`type;cfg`url];                                  //download & check each feed in cfg
  if[0<max count@'nq;                                                               //check for 0 being less than count of nq - FIX this check is wrong
    .lg.a "New questions in feeds, sending to slack";
    .slack.msg[.slack.hooks`publicq]@'raze fmt'[cfg`type;nq;cfg`name]               //format new messages without colour & send to slack
    ];
 }

\d .

.timer.add[`.feeds.tm;enlist .feeds.cfg;00:05:00;1b]                                //add timer to check every 5 minutes
