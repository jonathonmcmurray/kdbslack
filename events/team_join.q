\d .slack

events.team_join:{[e]
  if[not e[`user][`id] in .slack.userlist`id;                                       //check if this is a dupe notification etc.
     .slack.userlist,:"*SS"$`id`name`real_name#e`user;                              //add to user list so we don't welcome them twice
     .lg.o "Sending welcome msg to new user ",e[`user][`real_name]," (",e[`user][`name],")";
     postas[welcomemsg;e[`user][`id];"AquaQ Analytics Welcome"];                    //send welcome message as DM (via slackbot conversation)
    ];
 }

\d .slack
