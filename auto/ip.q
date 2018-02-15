\d .ip

getip:{.j.k[.Q.hg`:http://httpbin.org/ip]`origin}                                   //get & parse IP address
ip:getip[]

tm:{
  if[.ip.ip~n:getip[];
     .ip.ip:n;                                                                      //update stored IP address
     .slack.msg[.slack.hooks`homerstatus] "New IP address detected: ",n;     //msg about new IP
    ];
 }

\d .

.timer.add[`.ip.tm;`;00:05;1b]
