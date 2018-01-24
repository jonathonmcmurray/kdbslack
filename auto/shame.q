topcheck:30
shamethresh:70
toptab:([]pid:"i"%();user:0#`;mem:0#0f;cmd:0#`;time:0#.z.P)
shamed:([]time:0#.z.P;user:`)
gettop:{[x;y;z]toptab,:select from
  (update time:.z.P from `pid`user`mem`cmd xcol
    ("IS       F S";enlist",")0:","sv'{x where 0<count@'x}@'" "vs'6_system"top -bn1 -o \"%MEM\"") where mem>x;
  shame:(key exec avg mem by user from toptab where time>.z.P-"v"$y+5)except raze exec user from shamed where time>.z.P-"v"$900;
  if[count shame;
      .slack.msg[.slack.channels`general] "user:",(","sv string (),shame)," has averaged above ",string[x],"% memory for the last ",string[y],"s";
    `shamed insert (.z.P;first shame);];
  }

.shame.tm:{gettop[shamethresh;topcheck;x]}
