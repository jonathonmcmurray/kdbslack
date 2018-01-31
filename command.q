\l util/load.q
.load.dir`:util
.load.dir`:command
.timer.disable[]

/-- entrypoint --
.z.pp:{
  .post.raw,:enlist x:@[x;1;{.Q.id'[key x]!get x}];                                 //remove special chars from header names, store raw POST requests
  :.post[.post.ty?x[1]`ContentType;x[0]];                                           //lookup function based on Content-Type & pass payload
 }
