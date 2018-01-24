/-- general responses --
jrep:{.h.hy[`json] .j.j `response_type`text!(x;y)}                                  //generic function to build JSON response
pub:jrep["in_channel"]                                                              //broadcast a message publicly
ret:jrep["ephemeral"]                                                               //return a message, privately

/-- wiki --
t:("S*";enlist",")0:`:/home/jonny/output.csv;                                       //load csv of commands & links
t:update ssr[;"..";"http://code.kx.com/q/ref"]'[link] from t;                       //update links to be absolute
err:ret["Sorry, didn't find that word! Currently only KDB keywords are supported"]  //err message, returned privately
f.wiki:{n:select from t where name=x;$[0<count n;pub"\n" sv n`link;err]}            //lookup, if found public message, if not private error

/-- entrypoint --
.z.pp:{
  r:(!/)"S=&"0:.h.uh x 0;                                                           //parse incoming request into dict, replace escaped chars
  .bot.req,:enlist r;                                                               //keep record of incoming requests
  :f[`$1_r`command;`$r`text];                                                       //lookup function for this command (drop leading /), pass in params
 }
