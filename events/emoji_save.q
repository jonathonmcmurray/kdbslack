.slack.PATH:`:/home/jmcmurray/slackstats/emoji/

.slack.saveemoji:{[].slack.PATH upsert .slack.emojistats;.slack.emojistats:0#.slack.emojistats}

.timer.adddaily[`.slack.saveemoji;`;00:05;"0-6"]
