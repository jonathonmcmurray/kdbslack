\d .ud

lkup:{
  d:.j.k .Q.hg`$":http://api.urbandictionary.com/v0/define?term=",.h.hu x;          //get definition from API
  d:$["no_results"~d`result_type;                                                   //check we got a result
      "not found";                                                                  //if no result
      d[`list;w[til count d`list;`int$(-). d[`list][`thumbs_up`thumbs_down]];`definition]];  //randomly select based on weighting by upvotes
  :raze"The definition of ",x," is: ",d;                                            //return definition
 };

w:{[o;w]rand raze w#'o}                                                                  //choose an option based on weighting

f:{
  s:lkup x`text;                                                                    //lookup search term
  .slack.postase[s;x`channel_id;"urbanbot";":book:"];                               //post in channel as urbanbot
  :.slack.ok;                                                                       //suppress echoing of command in chat
 }

\d .

.cmd.ud:.ud.f
