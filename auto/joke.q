\d .joke

tm:{
  r:`:https://icanhazdadjoke.com "GET / HTTP/1.1\r\n",                              //HTTP request
                                 "Accept: application/json\r\n",
                                 "Host:icanhazdadjoke.com\r\n\r\n";
  j:.j.k (4+first r ss "\r\n\r\n")_r;                                               //trim HTTP headers off response
  .slack.msg[.slack.hooks`random] j`joke;                                           //post joke
 }

\d .

.timer.adddaily[`.joke.tm;`;10:30;"2-6"]                                            //add timer for daily run at 10:30, Mon-Fri
