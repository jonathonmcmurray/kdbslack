/ Levenshtein Distance
/ https://people.cs.pitt.edu/~kirk/cs1501/Pruhs/Spring2006/assignments/editdistance/Levenshtein%20Distance.htm
\d .util

lvn:{[s;t]
  n:count s;m:count t;
  if[n=0;:m];if[m=0;:n];
  d:(1+m;1+n)#0;
  d[0]:til 1+n;d[;0]:til 1+m;
  d:{[m;t;s;d;x]
     {[t;s;x;d;y] c:s[x]<>t[y];d[y;x]:min (d[y-1;x]+1;d[y;x-1]+1;d[y-1;x-1]+c);d}[t;s;x]/[d;1+til m]
   }[m;t;s]/[d;1+til n];
  :last last d;
 }

\d .
