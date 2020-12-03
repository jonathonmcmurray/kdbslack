\d .ip

getip:{.j.k[.Q.hg`:http://httpbin.org/ip]`origin}                                   //get & parse IP address
getip:{raze system"curl -s ipinfo.io/ip"}
ip:getip[]

validate:{(3=sum"."=x)&(all x in .Q.n,".")&all ("I"$"."vs x) within 0 255}          //check for 3 dots, all numbers & all with valid range

tm:{
  if[not .ip.ip~n:getip[];
     if[not validate n;.lg.w"invalid ip received:\n",n;:()];                        //return early if not a valid IP
     .ip.ip:n;                                                                      //update stored IP address
     .slack.msg[.slack.hooks`homerstatus] "New IP address detected: ",n;            //msg about new IP
    ];
 }

\d .

.timer.add[`.ip.tm;`;00:05;1b]
