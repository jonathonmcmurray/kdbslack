\d .qwz

/ config
channel:"pub-quizzing"

tm:{
 / Getting html object of joe website links
  root:"\n" vs .req.g"https://www.joe.co.uk/entertainment/pub-quiz" ;
 / Identify latest friday quiz link
  suffix:-2_9_first root where root like "*the-joe-friday-pub-quiz-week*";
 / form link
  link:"www.joe.co.uk/joe/the-joe-friday-pub-quiz",suffix;
 / post to slack
 .slack.postase[link;.slack.chanlist .qwz.channel;"pubQuizBot";":beers:"]
 };

.timer.adddaily[`.qwz.tm;`;14:00;6];
