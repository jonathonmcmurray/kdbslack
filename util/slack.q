\d .slack
token:raze read0`:config/slack_token                                                //load OAuth token for authentication
baseurl:`:https://slack.com/api                                                     //base URL for all API requests
url:{` sv baseurl,x}                                                                //shortcut for API URL generation

/-- webhooks --
hooks:exec channel!hook from ("S*";enlist",")0:`:config/channels.csv
msg:{[url;msg].Q.hp[hsym`$url;.h.ty`json].j.j enlist[`text]!enlist msg}

/-- responses --
jrep:{.h.hy[`json] .j.j `response_type`text!(x;y)}                                  //generic function to build JSON response
pub:jrep["in_channel"]                                                              //broadcast a message publicly
ret:jrep["ephemeral"]                                                               //return a message, privately

/-- api calls --
/the following are wrappers around slack API calls (of the same name) exposing very basic functionality
/for more advanced usage of these API calls, more sophisticated code will be necessary
channels.list:{.Q.hp[url`channels.list;.post.ty`form;.post.urlencode (1#`token)!enlist token]}
channels.info:{[chid].Q.hp[url`channels.info;.post.ty`form;.post.urlencode `token`channel!(token;chid)]}
chat.postMessage:{[chid;msg].Q.hp[url`chat.postMessage;.post.ty`form;.post.urlencode `token`channel`text!(token;chid;msg)]}
groups.list:{.Q.hp[url`groups.list;.post.ty`form;.post.urlencode (1#`token)!enlist token]}
groups.info:{[chid].Q.hp[url`groups.info;.post.ty`form;.post.urlencode `token`channel!(token;chid)]}
ims.list:{.Q.hp[url`ims.list;.post.ty`form;.post.urlencode (1#`token)!enlist token]}
ims.info:{[chid].Q.hp[url`ims.info;.post.ty`form;.post.urlencode `token`channel!(token;chid)]}
users.list:{.Q.hp[url`users.list;.post.ty`form;.post.urlencode (1#`token)!enlist token]}
users.info:{[uid].Q.hp[url`users.info;.post.ty`form;.post.urlencode `token`channel!(token;uid)]}

/-- wrappers --
/the following are more advanced wrappers than above for certain API calls
/these allow more specific actions to be taken in a simple manner

getchannelid:{[x]
  x:$[-11=type x;string x;x];                                                       //allow symbol input
  c:.j.k[channels.list[]]`channels;                                                 //get public channels
  g:.j.k[groups.list[]]`groups;                                                     //get private channels
  m:exec name!id from raze `name`id#/:(c;g);                                        //combine & make dictionary for mapping
  n:key[m]a?min a:.util.lvn[x]'[key m];                                             //find closest named channel
  :(n;m@n);                                                                         //return closest named channel & it's ID
 }

postas:{[m;c;u] /m-message,c-channel ID,u-user
  d:()!();                                                                          //create dictionary to build up API request
  d[`token]:token;
  d[`channel]:c;
  d[`text]:m;
  d[`as_user]:`false;
  d[`username]:u;
  .Q.hp[.slack.url`chat.postMessage;.post.ty`form;.post.urlencode d];               //send POST request to API URL
 }

\d .
