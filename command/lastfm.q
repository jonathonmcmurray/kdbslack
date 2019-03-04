\d .lfm

adduser:{
  if[not .lfm.valid[];                                                                          / check if cuntionality is enabled
    .lg.w"last.fm not enabled, user request cannot be made";
    :.slack.ret"functionality not enabled";                                                      / return status message privately
  ];
  p:.j.k[.slack.users.info x`user_id][`user;`profile];                                          / get user profile
  st:.lfm.u.handler[x`user_id;p`real_name;trim x`text];                                         / update last.fm username for user
  :.slack.ret st 1;                                                                             / return status message privately
 };

\d .

.cmd.lastfm:.lfm.adduser;
