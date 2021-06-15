/kx.q

dl.kx:{[url]
  :.Q.id .rss.get[url][`rss][`channel][`item];                                    //download & parse RSS XML
 }

chk.kx:{[id;kx]
  nq:select from kx where ("z"$"P"$dcdate)>.feeds.ldt[id];                           //select items that are new
  .feeds.ldt[id]:exec max "z"$"P"$dcdate from kx;                                    //update latest datetime
  nq:$[count nq;
       select from nq where not title like "[Rr][Ee]*";                             //filter out replies, only want new messages
       ()];
  :nq;
 }

link.k4:{x}
title.k4:{x}
user.k4:{x`dccreator}
