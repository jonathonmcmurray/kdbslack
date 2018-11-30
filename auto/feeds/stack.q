/stack.q

/-- main --
dl.stack:{[url]
  system"wget -o /dev/null -O /tmp/so-slack.json \"",url,"\"";                      //download silently with wget & save to /tmp
  so:.j.k raze system"cat /tmp/so-slack.json | gzip -d";                            //decompress return with gzip & parse as JSON
  hdel `$":/tmp/so-slack.json";                                                     //remove tmp file
  :so;                                                                              //return parsed JSON
 }

chk.stack:{[id;so]
  d:dt.stack so[`items;;`creation_date];                                            //get creation dates
  nq:so[`items] where d > .feeds.ldt[id];                                           //get list of new questions
  .feeds.ldt[id]:d[0];                                                              //update last date
  :nq;                                                                              //return list of new questions, empty if none
 }

link.stack:{x til last ss[x;"/"]}                                                   //trim link to remove unnecessary stating of question in URL
title.stack:ssr[;;{"c"$"I"$x except "&#;"}]/[;("&#??;";"$#???;")];                  //function to replace HTML encoded special chars e.g. &#39; -> '
user.stack:.[;(`owner;`display_name)];
dt.stack:{1970.01.01+x%24*3600};                                                    //calculate datetime based on seconds since UNIX epoch
