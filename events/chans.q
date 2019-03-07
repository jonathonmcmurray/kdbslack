\d .slack

events.channel_created:{
  .lg.o"Updating chanlist with ",x[`channel][`name]," id: ",x[`channel][`id];
  .slack.chanlist[x[`channel]`name]:x[`channel]`id
 }

events.channel_rename:events.channel_created
events.channel_deleted:{
  .lg.o"Removing ",x[`channel]," (",(.slack.chanlist?x`channel),") from chanlist";
  .slack.chanlist:(key[.slack.chanlist]except .slack.chanlist?x`channel)#.slack.chanlist
 }

\d .
