\d .status

tm:{
  .lg.i "Generating daily homer status report";                                     //alert for start of report generation
  .worker.create["workers/status.q";`.status.cb];                                   //use worker to run report generation in background process
 }

cb:{[m]
  .lg.i "Daily status report complete, sending";                                    //alert report has been received to callback
  .slack.msg[.slack.hooks`homerstatus] "\n" sv m;                                   //send report to slack
 }

\d .

.timer.adddaily[`.status.tm;`;09:00;"1-5"]                                          //add daily timer for report, 9am Mon-Fri
