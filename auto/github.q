\d .gh

issues:([  number:    `int$()]                              //keyed by number
            title:         ();
            state:       `$();
         comments:    `int$();
               pr:`boolean$();
         html_url:         ()
       )

token:raze read0`:config/gh_token
host:`:https://api.github.com
req:{[x]
  r:host "GET ",x," HTTP/1.1\r\n",
         "Host: ",(1_string host),"\r\n",
         "User-Agent: curl/7.47.0\r\n",                     //gh requires UA
         "Accept: */*\r\n",
         "Authorization: token ",token,"\r\n\r\n";
  :(4+first r ss "\r\n\r\n")_r;                             //remove HTTP header & return
 }

getissues:{[]
  j:.j.k req "/repos/toosuto-r/qchat/issues";               //get & parse to json
  :(distinct raze key@'j)#/:j;                              //return table by standardising keys of dicts
 }

upd:{[t] /t-table of updates from getissues
  t:@[t;`number`comments;`int$];                            //cast from floats to ints
  t:@[t;`state;`$];                                         //cast to symbol
  t:@[t;`pr;:;0<count@'t`pull_request];                     //get boolean of whether this is a PR
  t:`number`title`state`comments`pr`html_url#t;             //filter columns
  s:exec number!state from issues;                          //previous states
  c:exec number!comments from issues;                       //previous comments
  ni:select from t where not number in (0!.gh.issues)`number;   //new issues
  ns:select from t where state<>s number;                   //changed state
  nc:select from t where comments<>c number;                //new comments
  `.gh.issues upsert 1!t;                                   //upsert new records
  :(ni;ns;nc);                                              //return changes
 }

alrt:{[tl] /tl-table list - new issues, new state, new comments
  tl[1]:delete from tl[1] where number in tl[0]`number;     //ignore state changes for new issues
  tl[2]:delete from tl[2] where number in tl[0]`number;     //ignore new comments for new issues
  tl:@'[tl;`typ;:;`issue`state`comment];                    //type of change
  t:select distinct typ,first title,first comments,first pr,first state,first html_url by number from raze tl;
  m:{:$[`issue in x`typ;      ("New ",$[first x`pr;"PR";"issue"]," #",string[x`number];x`html_url);
        `state`comment~x`typ; ("New comments on #",string[x`number]," and state changed to ",string[x`state];x`html_url);
        `comment in x`typ;    ("New comments on #",string[x`number];x`html_url);
        `state in x`typ;      ("State of #",string[x`number]," changed to: ",string[x`state];x`html_url);
       ""];}@'0!t;
  m[;0]:(max count@'m[;0])$m[;0];                           //pad all strings to same length
  :"\n" sv " - " sv/:m;                                     //join URL onto each string, return full set of updates
 }

tm:{[]
  m:alrt upd getissues[];
  if[0<count m;.slack.msg[.slack.channels`jonathon.mcmurray]"qchat GitHub updates:\n",m];
 }

alrt upd getissues[];

\d .

.timer.add[`.gh.tm;`;00:05;1b]
