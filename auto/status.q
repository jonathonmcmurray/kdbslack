.status.tm:{
  .lg.i "Generating daily homer status report";
  .worker.create["workers/status.q";`.status.cb];
 }

.status.cb:{[m]
  .lg.i "Daily status report complete, sending";
  .slack.msg[.slack.channels`homerstatus] "\n" sv m;
 }
