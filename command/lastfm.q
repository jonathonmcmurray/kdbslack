\d .lfm

adduser:{[x]
  if[not .lfm.valid[];                                                                          / check if funtionality is enabled
    .lg.w"last.fm not enabled, user request cannot be made";
    :.slack.ret"functionality not enabled";                                                     / return status message privately
  ];
  r:exec from .slack.userlist where id like x`user_id;                                          / get details for current user
  .lg.o"Updating last.fm username for ",r[`real_name]," (",r[`name],")";
  st:.lfm.u.handler[x`user_id;r`real_name;trim x`text];                                         / update last.fm username for user
  :.slack.ret st 1;                                                                             / return status message privately
 };

\d .

.cmd.lastfm:.lfm.adduser;
