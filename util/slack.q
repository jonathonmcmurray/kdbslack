.slack.channels:exec channel!hook from ("S*";enlist",")0:`:config/channels.csv
.slack.msg:{[url;msg].Q.hp[hsym`$url;.h.ty`json].j.j enlist[`text]!enlist msg}
