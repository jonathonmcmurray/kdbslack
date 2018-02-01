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
chat.postMessage:{[chid;msg].Q.hp[url`chat.postMessage;.post.ty`json;`token`channel`text!(token;chid;msg)]}

\d .
