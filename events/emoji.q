/ parsing message & reaction events to gather emoji stats
\d .slack

emojistats:([]time:();emoji:();user:();channel:();react:();action:();id:();event_ts:())

getemoji:{
  c:.Q.hp[url`emoji.list;.post.ty`form;.post.urlencode (1#`token)!enlist token];            //download custom emoji
  d:.Q.hg`$":https://raw.githubusercontent.com/iamcal/emoji-data/master/emoji.json";        //download default emoji
  :string[key .j.k[c]`emoji],raze .j.k[d]@\:`short_names;                                   //return list of all emojis
 }
emojilist:getemoji[];                                                                       //build list

events.message:{
  .msgs.raw,:enlist enlist x;
  $[not `subtype in key x;
     newmsg;
    x[`subtype]~"message_deleted";
     rmmsg;
    x[`subtype]~"message_changed";
     editmsg;
     (::)
    ]x;
 }

emojirecord:{[r;a;i;c;u;t;e]
  `.slack.emojistats upsert (.z.p;e;u;c;r;a;i;t)
 }

newmsg:{
  if[count[emojistats];if[x[`event_ts]in emojistats`event_ts;:()]];                         //skip if we've already processed this
  e:(":"vs x`text) inter emojilist;                                                         //parse out list of emoji
  if[count e;emojirecord[0b;"A";x`client_msg_id;x`channel;x`user;x`event_ts]'[e]];          //record each used emoji
 }

editmsg:{
  if[count[emojistats];if[x[`event_ts]in emojistats`event_ts;:()]];                         //skip if we've already processed this
  e:(":"vs x[`message]`text) inter emojilist;                                               //get emoji in new message
  o:(":"vs x[`previous_message]`text) inter emojilist;                                      //get emoji in old message
  a:e except o;r:o except e;                                                                //added/removed emoji
  if[count a;emojirecord[0b;"A";x[`message]`client_msg_id;x`channel;x[`message]`user;x`event_ts]'[a]];   //added emoji
  if[count r;emojirecord[0b;"R";x[`message]`client_msg_id;x`channel;x[`message]`user;x`event_ts]'[r]];   //removed emoji
 }

rmmsg:{
  if[count[emojistats];if[x[`event_ts]in emojistats`event_ts;:()]];                         //skip if we've already processed this
  o:(":"vs x[`previous_message]`text) inter emojilist;                                      //get emoji in old message
  if[count o;emojirecord[0b;"R";x[`previous_message]`client_msg_id;x`channel;x[`previous_message]`user;x`event_ts]'[o]];   //removed emoji
 }

react:{[a;x]
  if[count[emojistats];if[x[`event_ts]in emojistats`event_ts;:()]];                         //skip if we've already processed this
  emojirecord[1b;a;"_"sv value x`item;x[`item]`channel;x`user;x`event_ts;x`reaction]
 }

events.reaction_added:react["A"]
events.reaction_removed:react["R"]
