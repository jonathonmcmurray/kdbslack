/post.q - utility functions for accepting POST requests of different types
\d .post

form:{
  r:(!/)"S=&"0:.h.uh x;                                                             //parse incoming request into dict, replace escaped chars
  .lg.i "received request for ",r[`command]," from ",r[`user_name];                 //log recieved request
  .bot.req,:enlist r;                                                               //keep record of incoming requests
  :.cmd[`$1_r`command;r];                                                           //lookup function for this command (drop leading /), pass in params
 }

json:{
  j:.j.k x;                                                                         //parse to JSON
  if[`challenge in key j;:j`challenge];                                             //for challenge parameter, respond with challenge value
  /-- handle other cases where we recieve JSON --
 }

ty:@[.h.ty;`form;:;"application/x-www-form-urlencoded"]                             //add type for url encoded form, used for slash commands

\d .
