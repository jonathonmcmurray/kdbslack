\d .worker

create:{[c;cb] /c:command for worker to run e.g. q script path,cb:callback function
  if[not system"p";system"p 0W";                                                    //if current proc not on a port, pick a random available one
     .lg.a "listening on port ",string system"p"];                                  //output new port
  p:string system"p";                                                               //get current port to give to worker for callback
  cb:string cb;                                                                     //convert callback function name to string
  .lg.i "starting worker process with ",c;                                          //log start of worker process
  system"q "," " sv (c;p;cb);                                                       //start bg process, telling it port & cb function to return to
 }

ret:{[x] /function for workers to use to return value
  (`$"::",.z.x 0)(cb:`$.z.x 1;x);                                                   //get port & callback function name from cmd line args, send return value
 }

\d .

\
Example usage:

q)-1 read0`:util/dummy_worker.q;
\l util/worker.q
system"sleep 10";
.worker.ret[1+1];
q).work.cb:{0N!x}
q).worker.create["util/dummy_worker.q";`.work.cb]
q)
q)
q)/not hung
q)2 /value returned from worker

