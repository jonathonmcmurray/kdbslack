\d .chlg

url:`:http://challenges.aquaq.co.uk/api/board.json                                  //url for API
st:count each .j.k .Q.hg url                                                        //get inital state

tm:{
  n:count each .j.k .Q.hg url;                                                      //download new board
  u:(where st<>n)#n-st;                                                             //get changes
  if[0<count u;                                                                     //if challenges completed, trigger message
     .slack.postase[;.slack.chanlist"aquachan";"Challenge Bot";":warning:"]         //send message with warning emoji as icon
     "Challenges completed in the last 5 mins:\n```",.Q.s[u],"```"                  //stringify dict
    ];
  st::n;                                                                            //update state
 }

\d .

.timer.add[`.chlg.tm;`;00:05;1b]                                                    //add timer to check every 5 mins
