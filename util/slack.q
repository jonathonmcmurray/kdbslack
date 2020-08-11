\d .slack
token:raze read0`:config/slack_token                                                //load OAuth token for authentication
baseurl:`:https://slack.com/api                                                     //base URL for all API requests
url:{` sv baseurl,x}                                                                //shortcut for API URL generation
welcomemsg:"\n" sv read0`:config/welcome_msg.txt;                                   //load welcome message

/-- webhooks --
hooks:exec channel!hook from ("S*";enlist",")0:`:config/channels.csv
msg:{[url;msg].Q.hp[hsym`$url;.h.ty`json].j.j enlist[`text]!enlist msg}

/-- responses --
jrep:{.h.hy[`json] .j.j `response_type`text!(x;y)}                                  //generic function to build JSON response
pub:jrep["in_channel"]                                                              //broadcast a message publicly
ret:jrep["ephemeral"]                                                               //return a message, privately
ok:"HTTP/1.1 200 OK\r\nConnection: close\r\n\r\n"                                   //simple no-content HTTP 200 OK message

/-- utilities --

taguser:{[uid] "<@",uid,">"}

/-- api calls --
/the following are wrappers around slack API calls (of the same name) exposing very basic functionality
/for more advanced usage of these API calls, more sophisticated code will be necessary
channels.list:{.Q.hp[url`channels.list;.post.ty`form;.post.urlencode (1#`token)!enlist token]}
channels.info:{[chid].Q.hp[url`channels.info;.post.ty`form;.post.urlencode `token`channel!(token;chid)]}
chat.postMessage:{[chid;msg].Q.hp[url`chat.postMessage;.post.ty`form;.post.urlencode `token`channel`text!(token;chid;msg)]}
groups.list:{.Q.hp[url`groups.list;.post.ty`form;.post.urlencode (1#`token)!enlist token]}
groups.info:{[chid].Q.hp[url`groups.info;.post.ty`form;.post.urlencode `token`channel!(token;chid)]}
im.list:{.Q.hp[url`im.list;.post.ty`form;.post.urlencode (1#`token)!enlist token]}
im.info:{[chid].Q.hp[url`im.info;.post.ty`form;.post.urlencode `token`channel!(token;chid)]}
users.list:{.Q.hp[url`users.list;.post.ty`form;.post.urlencode (1#`token)!enlist token]}
users.info:{[uid].Q.hp[url`users.info;.post.ty`form;.post.urlencode `token`user!(token;uid)]}
files.upload:{.req.postmulti[url`files.upload;@[x;`token;:;token]]}

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

getusers:{
  r:((k:`id`name`real_name),`deleted)#/:.j.k[.slack.users.list[]]`members;          //get list of all users currently signed up
  :"*SS"$/:k#select from r where not deleted;                                       //remove users that have been deleted
 }

postas0:{[m;c;u;i;e] /m-message,c-channel ID,u-user,i-icon,e-emoji
  d:()!();                                                                          //create dictionary to build up API request
  d[`token]:token;
  d[`channel]:c;
  d[`text]:m;
  d[`as_user]:`false;
  d[`username]:u;
  if[count i;d[`icon_url]:i];                                                       //if icon url is passed in, use it
  if[count e;d[`icon_emoji]:e];                                                     //if icon emoji is passed in, use it
  .Q.hp[.slack.url`chat.postMessage;.post.ty`form;.post.urlencode d];               //send POST request to API URL
 }

postas:postas0[;;;"";""]                                                            //projection to post as a username with default icon
postasi:postas0[;;;;""]                                                             //projection to post as username with icon URL
postase:postas0[;;;"";]                                                             //projection to post as username with emoji icon

userlist:getusers[];                                                                //get list of all valid users
chanlist:{c:.j.k[channels.list[]]`channels;g:.j.k[groups.list[]]`groups;exec name!id from raze `name`id#/:(c;g)}[]
\d .
