\d .hub

url:`:http://challenges.aquaq.co.uk/api/board.json
logo:"https://raw.githubusercontent.com/jonathonmcmurray/kdbslack/master/util/challengehub.png"

f:{
  d:desc count each .j.k .Q.hg url;                                                 //get leaderboard
  d:raze[{neg[count x]?x} each group d]#d;                                          //shuffle within levels
  .slack.postasi[;x`channel_id;"Challenge Bot";logo]                                //post with name & icon
     "Hey <@",x[`user_id],">, here's the current Challenge Hub leaderboard:\n```",  //tag the user who requested
     .Q.s[d],"```";                                                                 //format leaderboard
  :.slack.ok;                                                                       //send empty OK message to suppress command
 }

\d .

.cmd.hub:.hub.f
