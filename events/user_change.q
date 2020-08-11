\d .slack

events.user_change:{[e]
  if[e[`user]`deleted;                                                              //check if user has been deleted
     .lg.o"Removing user ",e[`user][`real_name]," (",e[`user][`name],")";
     :delete from .slack.userlist where id like e[`user]`id;                        //remove deleted user from user list
    ];
  .lg.o"Updating user ",e[`user][`real_name]," (",e[`user][`name],")";
  .slack.userlist,:"*SS"$`id`name`real_name#e`user;                                 //add updated details to user list
  .slack.userlist:select from .slack.userlist where i=(max;i)fby id;                //remove duplicate entries
 }

\d .slack
