\d .chlg


url:`:https://challenges.aquaq.co.uk/api/board.json                                 //url for API (board)
burl:`:https://challenges.aquaq.co.uk/api/badge.json                                //url for API (badge)
logo:"https://raw.githubusercontent.com/jonathonmcmurray/kdbslack/master/util/challengehub.png"
st:(`$.gh.members)#count each .j.k .Q.hg url                                        //get initial state (AQ only)
getbdgs:{.j.k .Q.hg burl};
bs:getbdgs[]                                                                        //get initial board state

bdgs:{
  a:.chlg.getbdgs[];                                                                //download badges
  n:w,'d w:where 0<count each d:a except'key[a]#bs;                                 //get new badges earnt
  postbdg each n;                                                                   //post all the new badges
  bs::a;
 }

postbdg:{
  nm:string x 0;                                                                    //name
  if[not nm in .gh.members;:()];                                                    //ignore non-AQ people
  msgs:nm,/:" earned the '",/:(1_x)[;0],\:"' badge";                                //messages to send
  m:("gold";"silver";"bronze");                                                     //list of possible medals
  icos:m first where m in (1_x)[;1];                                                //use icon of highest medal
  icos:":",icos,":";                                                                //add colons to make it an emoji
  .slack.postase[;.slack.chanlist"qquestions";"Badges Bot";icos]'[msgs];            //post message for each awarded badge
 }

tm:{
  n:count each .j.k .Q.hg url;                                                      //download new board
  n:(key[n]inter`$.gh.members)#n;                                                   //filter to only AQ people
  u:(where st<>n)#n-st;                                                             //get changes
  if[0<count u;                                                                     //if challenges completed, trigger message
     .slack.postasi[;.slack.chanlist"qquestions";"Challenge Bot";logo]              //send message with icon
     "Challenges completed in the last 5 mins:\n```",.Q.s[u],"```"                  //stringify dict
    ];
  st::n;                                                                            //update state
  bdgs[];                                                                           //check for badges
 }

\d .

.timer.add[`.chlg.tm;`;00:05;1b]                                                    //add timer to check every 5 mins
