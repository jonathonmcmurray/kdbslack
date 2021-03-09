\d .dog

postDog:{                                                                                       // post dog
  .lg.o"Running dog timer";
  if[not .dog.enabled;:.lg.w"doggo not enabled, dog timer aborted"];                            // exit if functionality disabled
  .lg.o"Posting daily dog to slack as doggobot in ",.dog.channel;
  j:.j.k .Q.hg["https://dog.ceo/api/breeds/image/random"];
  $[j[`status] like "success"; d:j`message; :.lg.e["Dog request failed"]];
  .slack.postasimge["";.slack.chanlist .dog.channel;"doggobot";":dog:";d];                      // post dog as doggobot
 };

\d .

if[.dog.enabled;                                                                                // only run if functionality is enabled
  .timer.adddaily[`.dog.postDog;`;10:30;"2-6"]                                                  // add timer for daily run at 10:30, Monday-Friday
 ];
