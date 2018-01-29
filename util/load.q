\d .load

dir:{
  k:key x:hsym$[10=type x;`$x;x];                                                   //get file list
  system@'"l ",/:1_'string ` sv'x,'k where k like "*.q";                            //filter to q files, load each
 }

\d .
