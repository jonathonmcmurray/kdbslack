# output from each line is piped to next line, equivalent to one liner above
ps -eo user:12,stime,args |    # get all running processes, output user name up to 12 chars
command grep torq         |    # find those that are torq processes (use "command" to bypass grep alias)
awk '{                                         # -- START AWK PROGRAM --
      if($3!="grep"&&$3!="bash"&&$3!="sh")     # ignore the grep process & bash/sh processes
      {printf "%-12s", $1;                     # output the username from each line
       for(i=1;i<=NF;i++)                      # iterate over all fields (split on space)
        {if($i=="-stackid")                    # find stackid field
          {printf "%-12s%s",$(i+1),$2}         # output next field i.e. actual port no, plus start time
        }
       printf "\n";                            # closing line
      }
     }'                   |                    # -- END AWK PROGRAM --
sort                      |    # sort the output alphabetically so duplicates are removed properly
uniq -c                   |    # remove duplicates and return list
awk '{printf "%-12s%-12s%-12s%-12s\n",$1,$2,$3,$4}'
