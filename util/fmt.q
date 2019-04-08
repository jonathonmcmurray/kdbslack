\d .fmt

fc:{[k;v]
  n:(1+count k:string k)|max {1+count[x]-sum"\303"=x}'[s:string v];
  p:{y,(x-count[y]-sum"\303"=y)#" "}[n];
  :enlist[p k],enlist[n#"-"],p'[s];
 }

t:{[t]
  c:flip(key;value)@\:flip t;
  :"\n"sv raze each flip fc .' c;
 }
