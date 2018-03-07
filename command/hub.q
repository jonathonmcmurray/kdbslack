\d .hub

url:`:http://challenges.aquaq.co.uk/api/board.json
logo:"https://raw.githubusercontent.com/jonathonmcmurray/kdbslack/master/util/challengehub.png"

f:{
  .slack.postasi[;x`channel_id;"Challenge Bot";logo]                                //post with name & icon
     "Hey <@",x[`user_id],">, here's the current Challenge Hub leaderboard:\n```",  //tag the user who requested
     .Q.s[desc count each .j.k .Q.hg url],"```";                                    //get & format leaderboard
  :.slack.ok;                                                                       //send empty OK message to suppress command
 }

\d .

.cmd.hub:.hub.f
