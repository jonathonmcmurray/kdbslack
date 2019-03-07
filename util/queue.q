/ work queue for doing jobs asynchronously (e.g. respond to HTTP request with 200 OK now, respond/react properly later)

\d .wk

q:()                                                                                //queue for jobs
dojob:{if[count q;t:q 0;.[value t 0;t 1;{.lg.e"queued work failed: ",x}];q::1_q]}   //pop top job & do it

\d .

.timer.add[`.wk.dojob;`;00:00:05;1b]                                                //check every 5 secs
