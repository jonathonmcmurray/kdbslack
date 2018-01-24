\l util/worker.q
m:enlist "```";
m,:"External IP: ",raze system"curl -s ipinfo.io/ip";
m,:"";
m,:"Speedtest Results:\n",-1_.Q.s (!/)"SS"$flip ": "vs/:system"speedtest --simple";
m,:"";
m,:"Disk Usage:";
m,:-1_.Q.s select from (.Q.id ("SSSSSS";enlist",")0:"," sv'{x where 0<count@'x}@'" " vs' system"df -h") where Mounted=`$"/home";
m,:"```";
.worker.ret[m];
