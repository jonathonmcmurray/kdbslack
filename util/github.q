/Adapted from GitHub example for reQ library
\d .gh

url:"https://api.github.com/"                                                       //basic URL
tk:.os.hread`.qgithub                                                               //read token file from home dir

linkparse:{(!/)flip({`$-1_5_x};except[;"<>"])@'/:reverse each trim ";"vs'","vs x}   //parse Link header to dict
getmembers:{[o] / o: organization
  rw:getraw url,"orgs/",o,"/members";                                               //get first page of members
  r:.j.k rw 1;h:rw 0;                                                               //parse body, extract header
  while[`next in key l:linkparse h`link;                                            //iterate through all pages
   rw:getraw l`next;                                                                //get next page
   r,:.j.k rw 1;h:rw 0;                                                             //parse & join body, extract header
  ];
  :r;
 }

.gh.get:.req.get[;enlist[`Authorization]!enlist"token ",tk]                         //get for GH with token
getraw:.req.send[`GET;;enlist[`Authorization]!enlist"token ",tk;();.req.VERBOSE]    //get for GH with token, keep headers

.gh.membertm:{
  .lg.o"Refreshing github members list";
  .gh.members:.gh.getmembers["AquaQAnalytics"]`login;                               //get member list for AQ (used to filter chlg hub stuff)
 }
.gh.membertm[];
