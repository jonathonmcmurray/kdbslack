\d .status

tm:{
  .lg.i "Generating daily homer status report";                                     //alert for start of report generation
  .worker.create["workers/status.q";`.status.cb];                                   //use worker to run report generation in background process
 }

cb:{[m]
  .lg.i "Daily status report complete, sending";                                    //alert report has been received to callback
  .slack.msg[.slack.hooks`homerstatus] m:"\n" sv m;                                 //send report to slack
  .teams.msg[.teams.hooks`kdbgeneral;"Homer Status - ",string .z.d;m];              //send report to Teams
 }

\d .

.timer.adddaily[`.status.tm;`;09:00;"2-6"]                                          //add daily timer for report, 9am Mon-Fri
