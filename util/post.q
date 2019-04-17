/post.q - utility functions for accepting POST requests of different types
\d .post

form:{
  r:(!/)"S=&"0:.h.uh ssr[x;"+";" "];                                                //parse incoming request into dict, replace escaped chars
  .lg.i "received request for ",r[`command]," from ",r[`user_name];                 //log recieved request
  .bot.req,:enlist r;                                                               //keep record of incoming requests
  :.cmd[`$1_r`command;r];                                                           //lookup function for this command (drop leading /), pass in params
 }

json:{
  j:.j.k x;                                                                         //parse to JSON
  if[`challenge in key j;:j`challenge];                                             //for challenge parameter, respond with challenge value
  if[`event in key j;.slack.event j];                                               //pass events into slack event handler
  /-- handle other cases where we recieve JSON --
 }

ty:@[.h.ty;`form;:;"application/x-www-form-urlencoded"]                             //add type for url encoded form, used for slash commands
hu:.h.hug .Q.an,"-.~"                                                               //URI escaping for non-safe chars, RFC-3986

urlencode:{[d] /d-dictionary
  k:key d;v:value d;                                                                //split dictionary into keys & values
  v:enlist each hu each @[v;where 10<>type each v;string];                          //string any values that aren't stringed,escape any chars that need it
  k:enlist each $[all 10=type@'k;k;string k];                                       //if keys are strings, string them
  :"&" sv "=" sv' k,'v;                                                             //return urlencoded form of dictionary
 }

.z.ac:{:(1;"slack")}                                                                //TODO implement proper auth of HTTP requests

\d .
