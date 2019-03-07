/-- events --
\d .slack

event:{[j]
  .wk.q,:enlist(`.slack.event0;enlist j);                                           //queue to process event
  :.slack.ok;                                                                       //return 200 OK to prevent repetition
 }

event0:{[j]
  e:j`event;                                                                        //extract event
  if[(t:`$e`type) in key events;events[t] e];                                       //pass to handler for event
  if[not t in key .slack.events;.lg.w"Unhandled event: ",string t];                 //warn about unhandled events
 }

\d .slack
