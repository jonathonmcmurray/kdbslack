\d .box

f:{
   i:x`text;                                                                        //extract text to boxify
   s:.slack.taguser[x`user_id],"\n",                                                //tag user requesting box
     "```",                                                                         //start code block
     "╔",((3*1+2*count i)#"═"),"╗\n",                                               //top line
     "║",(raze " ",'upper i)," ║\n",                                                //box contents
     "╚",((3*1+2*count i)#"═"),"╝",                                                 //bottom line
     "```";                                                                         //end code block
   .slack.postas[s;x`channel_id;"kdbbot"];                                          //post as kdbbot into channel
   :.slack.ok;                                                                      //return empty OK status to suppress command
 }

\d .

.cmd.b:.box.f
