.timer.jobs:([] id:       `int$();  //identifier for job
                function:    `$();  //function to run
                args:          ();  //arguments to be passed (list)
                period:  `time$();  //periodicity with which to run job
                lst:`timestamp$();  //last time job was run
                re:   `boolean$()   //recurring, if false delete after running
            );

.timer.run:{[x]
  t:select from .timer.jobs where period<x-lst;             //get jobs that need run
  if[count t;
     t[`function] .' t[`args];                              //run all necessary jobs
     delete from `.timer.jobs where id in t`id,not re;      //delete any jobs we ran that aren't recurring
     update lst:x from `.timer.jobs where id in t`id;       //update last run time for job we ran
    ];
 };

.timer.add:{[f;a;p;r]
  id:$[count .timer.jobs;1+max .timer.jobs`id;0];
  .lg.i "Adding timer job for function ",string f;
  `.timer.jobs upsert enlist cols[.timer.jobs]!(id;f;(),a;`time$p;.z.P;r);
 }

.timer.rm:{[i]
  delete from `.timer.jobs where id=i;
 }

.z.ts:.timer.run
system"t 5000"
