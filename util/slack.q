\d .slack

/-- webhooks --
channels:exec channel!hook from ("S*";enlist",")0:`:config/channels.csv
msg:{[url;msg].Q.hp[hsym`$url;.h.ty`json].j.j enlist[`text]!enlist msg}

/-- responses --
jrep:{.h.hy[`json] .j.j `response_type`text!(x;y)}                                  //generic function to build JSON response
pub:jrep["in_channel"]                                                              //broadcast a message publicly
ret:jrep["ephemeral"]                                                               //return a message, privately

\d .
