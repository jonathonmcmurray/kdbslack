\d .qwz

/ config
channel:"pub-quizzing"

getQuiz:{
 / Getting json object of joe website links
  root:system "wget -q https://www.joe.co.uk/joe/the-joe-friday-pub-quiz -O -";
 / Identify latest friday quiz link
  suffix:-2_9_first root where root like "*the-joe-friday-pub-quiz-week*";
 / form link
  link:"www.joe.co.uk/joe/the-joe-friday-pub-quiz",suffix;
 / post to slack
 .slack.postase[link;.slack.chanlist .qwz.channel;"pubQuizBot";":beers:"]
 };

.timer.add[`.qwz.getQuiz;`;07D00:00;1b];
