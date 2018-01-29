\d .timer

jobs:([] id:       `int$();                                                         //identifier for job
         function:    `$();                                                         //function to run
         args:          ();                                                         //arguments to be passed (list)
         period:  `time$();                                                         //periodicity with which to run job
         lst:`timestamp$();                                                         //last time job was run
         re:   `boolean$()                                                          //recurring, if false delete after running
     );

run:{[x]
  t:select from jobs where period<x-lst;                                            //get jobs that need run
  if[count t;
     e:{.lg.e "Error running ",string[x]," : ",y}@'t`function;                      //error handler projections for each function
     .'[value@'t`function;t`args;e];                                                //run necessary jobs with error catching
     delete from `.timer.jobs where id in t`id,not re;                              //delete any jobs we ran that aren't recurring
     update lst:x from `.timer.jobs where id in t`id;                               //update last run time for job we ran
    ];
 };

add:{[f;a;p;r]
  id:$[count jobs;1+max jobs`id;0];
  .lg.i "Adding timer job for function ",string f;
  `.timer.jobs upsert enlist cols[jobs]!(id;f;(),a;`time$p;.z.P;r);
 }

rm:{[x]
  delete from `.timer.jobs where id=x;
 }

enable:{system"t ",string $[type[x]within -19 -16;`int$`time$x;x]}
disable:{enable 0}

\d .

.z.ts:.timer.run
.timer.enable 00:00:05
