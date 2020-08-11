\d .fmt

fc:{[k;v]
  n:(1+.utf.unicount k:string k)|max {1+.utf.unicount[x]-sum"\303"=x}'[s:string v];
  p:{y,(x-.utf.unicount[y]-sum"\303"=y)#" "}[n];
  :enlist[p k],enlist[n#"-"],p'[s];
 }

t:{[t]
  c:flip(key;value)@\:flip t;
  :"\n"sv raze each flip fc .' c;
 }
