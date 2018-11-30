\d .load

dir:{
  k:key x:hsym$[10=type x;`$x;x];                                                   //get file list
  p:$[`order.txt in key x;` sv'x,'`$read0` sv x,`order.txt;()];                     //priority
  system@'"l ",/:1_'string p,(` sv'x,'k where k like "*.q")except p;                //filter to q files, load each
 }

\d .
