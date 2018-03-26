\d .timer

jobs:([] id:       `int$();                                                         //identifier for job
         function:    `$();                                                         //function to run
         args:          ();                                                         //arguments to be passed (list)
         period:  `time$();                                                         //periodicity with which to run job (or time to run at for daily job)
         lst:`timestamp$();                                                         //last time job was run
         re:   `boolean$();                                                         //recurring, if false delete after running
         days:          ()                                                          //days to run a daily job on
     );

run:{[x]
  t:select from jobs where period<x-lst,0=count@'days;                              //get regular jobs that need run
  t,:select from jobs where mod[`date$x;7]in/:days,("d"$lst)<"d"$x,period<`time$x;  //join daily jobs that need run
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
  `.timer.jobs upsert enlist cols[jobs]!(id;f;(),a;`time$p;.z.P;r;());
 }

days:{[x]
  :distinct raze {@[x;where 2=count@'x;{x[0]+til 1+x[1]-x 0}]}"J"$"-" vs'"," vs x;  //take string like "1,2,3-5,7", return list of corresponding days
 }

adddaily:{[f;a;t;d]
  d:$[10=type d;days d;d];                                                          //accept string or list of days
  id:$[count jobs;1+max jobs`id;0];                                                 //id for new job
  .lg.i "Adding daily timer job for function ",string f;                            //log addition
  `.timer.jobs upsert enlist cols[jobs]!(id;f;(),a;`time$t;.z.P;1b;d);              //add to jobs table
 }

rm:{[x]
  delete from `.timer.jobs where id=x;
 }

enable:{system"t ",string $[type[x]within -19 -16;`int$`time$x;x]}
disable:{enable 0}

\d .

.z.ts:{.timer.run .z.P}                                                             //run timer with local time
