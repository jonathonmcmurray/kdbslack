\d .quote

dl:{.j.k .Q.hg`$":http://quotes.rest/qod.json?category=inspire"}                    //download & parse to JSON

tm:{
  q:dl[];                                                                           //get new quote
  .slack.msg[.slack.channels`general]                                               //post to #general
    "\n - " sv q[`contents;`quotes;0;`quote`author];                                //post quote & author
 }

\d .

.timer.adddaily[`.quote.tm;`;16:00;"1-5"]                                           //add timer for daily run at 4PM, Mon-Fri
