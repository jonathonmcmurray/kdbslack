.joke.tm:{
  r:`:https://icanhazdadjoke.com "GET / HTTP/1.1\r\nAccept: application/json\r\nHost:icanhazdadjoke.com\r\n\r\n";
  j:.j.k (4+first r ss "\r\n\r\n")_r;
  .slack.msg[.slack.channels`random] j`joke;
 }

.timer.add[`.joke.tm;`;24:00;1b]
