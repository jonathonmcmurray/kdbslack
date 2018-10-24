\d .box

f:{
   i:x`text;                                                                        //extract text to boxify
   s:"```",                                                                         //start code block
     "╔",((3*1+2*count i)#"═"),"╗\n",                                               //top line
     "║",(raze " ",'upper i)," ║\n",                                                //box contents
     "╚",((3*1+2*count i)#"═"),"╝",                                                 //bottom line
     "```";                                                                         //end code block
   p:.j.k[.slack.users.info x`user_id][`user;`profile];                             //get user profile
   nm:p$[enlist[""]~p`display_name;`display_name;`real_name];                       //get name
   img:p`image_original;                                                            //get profile pic
   .slack.postasi[s;x`channel_id;nm;img];                                           //post as user into channel
   :.slack.ok;                                                                      //return empty OK status to suppress command
 }

\d .

.cmd.b:.box.f
