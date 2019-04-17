\d .df

lkup:{
  j:.j.k .Q.hg `$"https://api.pearson.com/v2/dictionaries/ldoce5/entries?headword=",.h.hu x;    //query API for definition
  t:$[count j`results;@[rand[j[`results]][`headword`senses];1;{raze raze x`definition}];""];    //extract random matched word & definition from list
  d:$[2>count t;(x;"No Results Found");t];                                          //if nothing found, no results
  :raze"The definition of ",d[0]," is: ",d 1;                                       //return definition
 };

f:{
  s:lkup x`text;                                                                    //lookup search term
  .slack.postase[s;x`channel_id;"dictbot";":book:"];                                //post to channel
  :.slack.ok;                                                                       //suppress echoing of command in channel
 }

\d .

.cmd.df:.df.f
