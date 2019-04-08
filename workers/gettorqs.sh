# output from each line is piped to next line, equivalent to one liner above
ps -eo user:12,stime,args |    # get all running processes, output user name up to 12 chars
command grep 'q*torq.q'   |    # find those that are torq processes (use "command" to bypass grep alias)
awk '{                                         # -- START AWK PROGRAM --
      if($3!="grep"&&$3!="bash"&&$3!="sh")     # ignore the grep process & bash/sh processes
      {printf "%-20s", $1;                     # output the username from each line
       for(i=1;i<=NF;i++)                      # iterate over all fields (split on space)
        {if($i=="-stackid")                    # find stackid field
          {printf "%-20s%s",substr($(i+1),1,16),$2}         # output next field i.e. actual port no, plus start time
        }
       printf "\n";                            # closing line
      }
     }'                   |                    # -- END AWK PROGRAM --
sort                      |    # sort the output alphabetically so duplicates are removed properly
uniq -c                   |    # remove duplicates and return list
awk '{printf "%-20s%-20s%-20s%-20s\n",$1,$2,$3,$4}'
