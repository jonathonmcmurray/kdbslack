\l util/log.q

/-- general responses --
jrep:{.h.hy[`json] .j.j `response_type`text!(x;y)}                                  //generic function to build JSON response
pub:jrep["in_channel"]                                                              //broadcast a message publicly
ret:jrep["ephemeral"]                                                               //return a message, privately

/-- wiki --
t:("S*";enlist",")0:`:config/wiki.csv;                                              //load csv of commands & links
t:update ssr[;"..";"http://code.kx.com/q/ref"]'[link] from t;                       //update links to be absolute
err:ret["Sorry, didn't find that word! Currently only KDB keywords are supported"]  //err message, returned privately
f.wiki:{
  n:select from t where name=`$x`text;                                              //lookup
  if[0=count n;.lg.e "lookup failed for ",x`text];                                  //log error if not found
  $[0<count n;pub"\n" sv n`link;err]}                                               //if found public message, if not private error

/-- entrypoint --
.z.pp:{
  r:(!/)"S=&"0:.h.uh x 0;                                                           //parse incoming request into dict, replace escaped chars
  .lg.i "received request for ",r[`command]," from ",r[`user_name];                 //log recieved request
  .bot.req,:enlist r;                                                               //keep record of incoming requests
  :f[`$1_r`command;r];                                                              //lookup function for this command (drop leading /), pass in params
 }
