\l util/worker.q
m:enlist "```";

/-- uptime --
m,:(1_raze system"uptime";"")

/-- external IP --
/m,:"External IP: ",.j.k[.Q.hg`:http://httpbin.org/ip]`origin;
m,:"External IP: ",raze system"curl -s ipinfo.io/ip";
m,:"";

/-- speedtest --
m,:"Speedtest Results:\n",-1_.Q.s (!/)"SS"$flip ": "vs/:system"speedtest --simple";

/-- disk usage --
m,:("";"Disk Usage:");
m,:-1_.Q.s select from (.Q.id ("SSSSSS";enlist",")0:"," sv'{x where 0<count@'x}@'" " vs' system"df -h") where Mounted in `$("/home";"/data");

/-- TorQ stacks --
t:flip `count`user`stackid`stime!("ISIS";4#20)0:system"bash workers/gettorqs.sh"
/t:select from t where not stackid in 9800 13400                                     //filter out prodsupport team regular stacks
t:select from t where not user in `devops1`fxcm
if[0<count t;
   m,:("";"Running TorQ stacks");
   m,:-1_.Q.s t
  ];

m,:"```";
.worker.ret[m];

exit 0;
