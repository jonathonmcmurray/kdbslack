\d .status

tm:{
  .lg.i "Generating daily homer status report";                                     //alert for start of report generation
  .worker.create["workers/status.q";`.status.cb];                                   //use worker to run report generation in background process
 }

cb:{[m]
  .lg.i "Daily status report complete, sending";                                    //alert report has been received to callback
  .slack.msg[.slack.channels`homerstatus] "\n" sv m;                                //send report to slack
 }

\d .

.timer.add[`.status.tm;`;24:00;1b]                                                  //add daily timer for report
update lst:.z.D+09:00 from `.timer.jobs where function=`.status.tm;                 //adjust last run time to 9AM today so report runs at 9AM tomorrow
