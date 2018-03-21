\d .flip

f:{
  c:rand("heads";"tails");                                                          //pick result
  s:.slack.taguser[x`user_id]," flipped a ",c;                                      //generate string
  .slack.postase[s;x`channel_id;"coinflip bot";":purse:"];                          //post to chat
  :.slack.ok;                                                                       //suppress echoing of command
 }

g:{
  c:rand ","vs x`text;                                                              //pick result
  s:.slack.taguser[x`user_id]," spun the wheel containing: ",x[`text],              //generate string & tag user
                              "\nand it came up: ",c;
  .slack.postase[s;x`channel_id;"Spin the Wheel bot";":ferris_wheel:"];             //post to chat
  :.slack.ok;                                                                       //suppress echoing of command
 }

\d .

.cmd.flip:.flip.f
.cmd.spin:.flip.g
