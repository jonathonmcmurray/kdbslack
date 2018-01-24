\l util/slack.q
\l util/log.q
\l util/timer.q
\l util/worker.q

\l auto/feeds.q
\l auto/shame.q
\l auto/status.q

.timer.add[`.feeds.tm;enlist .feeds.cfg;00:05:00;1b]
.timer.add[`.status.tm;`;24:00;1b]
update lst:.z.D+09:00 from `.timer.jobs where function=`.status.tm;
.timer.add[`.shame.tm;`;00:00:30;1b]
