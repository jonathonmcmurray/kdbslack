/k4.q

xmlparse:`:./expat 2:(`xmlparse;1)

dl.k4:{[url]
  :xmlparse .Q.hg hsym `$url;                                                       //download & parse RSS XML
 }

chk.k4:{[id;k4]
  d:"Z"$1_k4[0][1][;1;;1]@'k4[0][1][;1;;0]?\:`$"dc:date";                           //get dates for items
  nq:k4[0;1;1+where d>.feeds.ldt[id];1];                                            //select items that are new
  .feeds.ldt[id]:max d;                                                             //update latest datetime
  nq:(!/) each flip each nq;                                                        //format to dictionaries
  nq:$[count nq;
       select from nq where not title like "[Rr][Ee]*";                             //filter out replies, only want new messages
       ()];
  :nq;
 }

link.k4:{x}
title.k4:{x}
user.k4:{x`$"dc:creator"}
