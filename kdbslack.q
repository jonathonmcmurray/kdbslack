/ have to load load.q manually, then can use loaddir function
\l util/load.q
.load.dir`util                                                                      //always load util directory, essentials

.proc.args:.Q.opt .z.x;                                                             //get process args

if[`load in key .proc.args;@[`.proc.args;`load;{`$","vs first x}]];                 //if load args passed in, split & convert to symbols
.load.dir each .proc.args[`load];                                                   //load everything from command line

if[`timer in key .proc.args;.timer.enable 00:00:05];                                //if timer arg passed, enable timer on 5 seconds

if[`post in key .proc.args;                                                         //if post arg passed, define POST handler
   .z.pp:{
     .post.raw,:enlist x:@[x;1;{.Q.id'[key x]!get x}];                              //remove special chars from header names, store raw POST requests
     :.post[.post.ty?x[1]`ContentType;x[0]];                                        //lookup function based on Content-Type & pass payload
    }
  ];

if[not system"p";system"p 0W"];                                                     //make sure to open a port, if none specified on cmd line
.lg.a "Running on port :",string system"p";                                         //output the running port
