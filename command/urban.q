\d .ud

lkup:{
  d:.j.k .Q.hg`$":http://api.urbandictionary.com/v0/define?term=",x;                //get definition from API
  d:$["no_results"~d`result_type;                                                   //check we got a result
      "not found";                                                                  //if no result
      rand d[`list;where s>0.25*max[s:sum d[`list;`thumbs_up`thumbs_down]];`definition]];   //randomly select where >25% of max votes
  :raze"The definition of ",x," is: ",d;                                            //return definition
 };

f:{
  s:lkup x`text;                                                                    //lookup search term
  .slack.postase[s;x`channel_id;"urbanbot";":book:"];                               //post in channel as urbanbot
  :.slack.ok;                                                                       //suppress echoing of command in chat
 }

\d .

.cmd.ud:.ud.f
