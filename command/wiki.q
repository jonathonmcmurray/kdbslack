\d .wiki

t:("S*";enlist",")0:`:config/wiki.csv;                                                      //load csv of commands & links
t:update ssr[;"..";"http://code.kx.com/q/ref"]'[link] from t;                               //update links to be absolute
err:.slack.ret["Sorry, didn't find that word! Currently only KDB keywords are supported"]   //err message, returned privately
f:{
  n:select from t where name=`$x`text;                                                      //lookup
  if[0=count n;.lg.e "lookup failed for ",x`text];                                          //log error if not found
  $[0<count n;.slack.pub"\n" sv n`link;err]}                                                //if found public message, if not private error

\d .

.cmd.wiki:.wiki.f                                                                           //register command function
