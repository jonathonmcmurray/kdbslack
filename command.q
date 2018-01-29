\l util/load.q
.load.dir`:util
.load.dir`:command
.timer.disable[]

/-- entrypoint --
.z.pp:{
  r:(!/)"S=&"0:.h.uh x 0;                                                           //parse incoming request into dict, replace escaped chars
  .lg.i "received request for ",r[`command]," from ",r[`user_name];                 //log recieved request
  .bot.req,:enlist r;                                                               //keep record of incoming requests
  :.cmd[`$1_r`command;r];                                                           //lookup function for this command (drop leading /), pass in params
 }
