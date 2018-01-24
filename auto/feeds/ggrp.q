/ggrp.q

/-- util funcs --
.ggrp.txt:@[;`$"#text"];

/-- main --
dl.ggrp:{[url]
  `:/tmp/gg.xml 0: enlist .Q.hg hsym `$url;                         //download silently & save to /tmp
  gg:.j.k raze system"python util/xml2json.py -t xml2json /tmp/gg.xml";  //parse XML to JSON
  hdel `:/tmp/gg.xml;                                               //remove tmp file
  :gg;                                                              //return parsed JSON
 }

chk.ggrp:{[id;gg]
  d:dt.ggrp gg[`rss;`channel;`item;;`pubDate];                      //get creation dates
  nq:gg[`rss;`channel;`item] where d > .feeds.ldt[id];              //get list of new questions
  .feeds.ldt[id]:d[0];                                              //update last date
  :nq;                                                              //return list of new questions, empty if none
 }

link.ggrp:.ggrp.txt
title.ggrp:.ggrp.txt
user.ggrp:{1_.ggrp.txt x`author}
dt.ggrp:{"Z"$raze system@'"date --date='",/:$[10=type x;enlist x;x],\:"' +%Y.%m.%dT%H:%M:%S"}
