.status.tm:{
  .lg.i "Generating daily homer status report";
  .worker.create["workers/status.q";`.status.cb];
 }

.status.cb:{[m]
  .lg.i "Daily status report complete, sending";
  .slack.msg[.slack.channels`homerstatus] "\n" sv m;
 }

.timer.add[`.status.tm;`;24:00;1b]
update lst:.z.D+09:00 from `.timer.jobs where function=`.status.tm;
