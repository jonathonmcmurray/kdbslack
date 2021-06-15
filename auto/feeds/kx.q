/kx.q

dl.kx:{[url]
  kx:.rss.get[url][`rss][`channel];                                                 //download & parse RSS XML
  :$[`item in key kx;.Q.id $[99h=type kx`item;enlist;]kx[`item];()];
 }

chk.kx:{[id;kx]
  if[kx~();:()];
  nq:select from kx where ("z"$"P"$dcdate)>.feeds.ldt[id];                           //select items that are new
  .feeds.ldt[id]:exec max "z"$"P"$dcdate from kx;                                    //update latest datetime
  nq:$[count nq;
       select from nq where not title like "[Rr][Ee]*";                             //filter out replies, only want new messages
       ()];
  :nq;
 }

link.kx:{x}
title.kx:{x}
user.kx:{x`dccreator}
