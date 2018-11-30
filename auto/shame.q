\d .shame

topcheck:30
shamethresh:70
toptab:([]pid:"i"%();user:0#`;mem:0#0f;cmd:0#`;time:0#0Np)
shamed:([]time:0#.z.P;user:`)
users:system"cut -d: -f1 /etc/passwd"

gettop:{[x;y;z]
  top:","sv'{x where 0<count each x}each" "vs'6_system"top -bn1 -o \"%MEM\"";       //dump top output to in-mem CSV
  t:update time:.z.P from `pid`user`mem`cmd xcol ("IS       F S";enlist",")0:top;   //parse to KDB table
  t:select from t where mem>x;                                                      //get anything over threshold
  t:update user:`${users a?min a:.util.lvn[x]@'users}'[string user] from t;         //convert truncated names to real user names
  toptab,:t;                                                                        //append to toptab
  rs:raze exec user from shamed where time>.z.P-"v"$900;                            //recent shamees
  shame:(key exec avg mem by user from toptab where time>.z.P-"v"$y+5)except rs;    //those to be shamed now
  if[count shame;
     msg:"user:",(","sv string (),shame)," has averaged above ",                    //construct message for sending to slack
          string[x],"% memory for the last ",string[y],"s";
     .slack.msg[.slack.hooks`general;msg];                                          //send message
     `.shame.shamed insert (.z.P;first shame);                                      //add to shamed list to prevent re-shaming
    ];
 }

.shame.tm:{gettop[shamethresh;topcheck;x]}

\d .

.timer.add[`.shame.tm;`;00:00:30;1b]
