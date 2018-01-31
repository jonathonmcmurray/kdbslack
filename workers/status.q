\l util/worker.q
m:enlist "```";

/-- uptime --
m,:(1_raze system"uptime";"")

/-- external IP --
m,:"External IP: ",.j.k[.Q.hg`:http://httpbin.org/ip]`origin;
m,:"";

/-- speedtest --
m,:"Speedtest Results:\n",-1_.Q.s (!/)"SS"$flip ": "vs/:system"speedtest --simple";

/-- disk usage --
m,:("";"Disk Usage:");
m,:-1_.Q.s select from (.Q.id ("SSSSSS";enlist",")0:"," sv'{x where 0<count@'x}@'" " vs' system"df -h") where Mounted=`$"/home";

/-- TorQ stacks --
t:flip `count`user`stackid`stime!("ISIS";4#12)0:system"bash workers/gettorqs.sh"
if[0<count t;
   m,:("";"Running TorQ stacks");
   m,:-1_.Q.s t
  ];

m,:"```";
.worker.ret[m];
