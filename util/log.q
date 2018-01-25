.lg.lvls:`err`wrn`inf`alt!("ERROR";"WARN";"INFO";"ALERT")           //define log level strings
.lg.lvls:max[count@'.lg.lvls]$.lg.lvls                              //pad all to max length

.lg.cols:`err`wrn`inf`alt!31 33 0 34                                //define colours for each log level

.lg.lg:{[lvl;msg]
  -1 "\033[G[ ",string[.z.Z]," ] [ \033[",string[.lg.cols lvl],"m",.lg.lvls[lvl],"\033[0m ] ",msg;
 }

.lg.o:.lg.i:.lg.lg[`inf]
.lg.w:.lg.lg[`wrn]
.lg.e:.lg.lg[`err]
.lg.a:.lg.lg[`alt]
