\d .sl

f:{
  /s:lkup x`text;                                                                    //lookup search term
  s:"Sleeps until...",", "sv("Santa: ";"AoC: ";"Party: "),'string-[;.z.d]24 0 7+`date$a+11-mod[a:`month$.z.d;12];
  .slack.postase[s;x`channel_id;"sleepbot";":parrot_sleep:"];                       //post to channel
  :.slack.ok;                                                                       //suppress echoing of command in channel
 }

\d .

.cmd.sl:.sl.f
