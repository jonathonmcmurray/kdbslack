// utilities for downloading & parsing RSS feeds into useful kdb objects

\d .rss

// load expat library for XML parsing
xmlparse:`:./expat 2:(`xmlparse;1)

// combine dictionaries (like raze, but without overwriting keys)
.rss.combdict:{[x]
    // group together like keys
    g:group first each key each x;
    p:(first each value each x)g;
    // atomize any individual keys
    :@[p;where 1=count each g;first];
 }

.rss.parse:{[p] / p - XML parsed by expat
    // iterate through & use XML tag as keys in nested dictionaries
    :$[0=t:type first p;.rss.combdict .z.s'[p];-11h=t;enlist[first p]!enlist .z.s[p 1];p];
 }

// download and parse an RSS feed
.rss.get:{[url] / url - RSS URL as string or hsym
    // download & parse with expat
    xml:xmlparse .Q.hg url;
    // parse into more useful kdb object
    :.rss.parse xml;
 }

\d .