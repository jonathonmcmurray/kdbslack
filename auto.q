/ have to load load.q manually, then can use loaddir function
\l util/load.q
.load.dir`:util
.load.dir`:auto

if[not system"p";system"p 0W"];
.lg.a "Running on port :",string system"p";
