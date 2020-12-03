/ os.q taken from https://github.com/jonathonmcmurray/qutil_packages @ beaabdd

\d .os

es:$[.z.o like "w*";" 2>NUL";" 2>/dev/null"];                                       //error suppression dependent on os
test:{[x]
  /* .os.test - test if a command works on current os */
  :@[{system x;1b};x,es;0b];                                                        //run with system & suppress error
  }

home:hsym`$getenv$[.z.o like "w*";`USERPROFILE;`HOME]                               //get home dir depending on OS
hfile:(` sv home,)                                                                  //get file path relative to home dir

read:{$[1=count a;first;]a:read0 x}                                                 //read text file, single string if one line
write:{x 0:$[10=type y;enlist;]y}                                                   //write text file, list of strings or single

hread:{read hfile x}                                                                //read file from home dir
hwrite:{write[hfile x;y]}                                                           //write file in home dir

\d .

\d .url

// @kind function
// @category private
// @fileoverview Parse URL query; split on ?, urldecode query
// @param x {string} URL containing query
// @return {(string;dict)} (URL;parsed query)
query:{[x]@["?"vs x;1;dec]}                                                         //split on ?, urldecode query

// @kind function
// @category private
// @fileoverview parse a string/symbol/hsym URL into a URL dictionary
// @param q {boolean} parse URL query to kdb dict
// @param x {string|symbol|#hsym} URL containing query
// @return {dict} URL dictionary
parse0:{[q;x]
  if[x~hsym`$255#"a";'"hsym too long - consider using a string"];                   //error if URL~`: .. too long
  x:sturl x;                                                                        //ensure string URL
  p:x til pn:3+first ss[x;"://"];                                                   //protocol
  uf:("@"in x)&first[ss[x;"@"]]<first ss[pn _ x;"/"];                               //user flag - true if username present
  un:pn;                                                                            //default to no user:pass
  u:-1_$[uf;(pn _ x) til (un:1+first ss[x;"@"])-pn;""];                             //user:pass
  d:x til dn:count[x]^first ss[x:un _ x;"/"];                                       //domain
  a:$[dn=count x;enlist"/";dn _ x];                                                 //absolute path
  o:`protocol`auth`host`path!(p;u;d;a);                                             //create URL object
  :$[q;@[o;`path`query;:;query o`path];o];                                          //split path into path & query if flag set, return
  }

// @kind function
// @category private
// @fileoverview parse a string/symbol/hsym URL into a URL dictionary & parse query
// @param x {string|symbol|#hsym} URL containing query
// @return {dict} URL dictionary
// @qlintsuppress RESERVED_NAME
.url.parse:parse0[1b]                                                               //projection to parse query by default

// @kind function
// @category private
// @fileoverview format URL object into string
// @param x {dict} URL dictionary
// @return {string} URL
format:{[x]
  :raze[x`protocol`auth],$[count x`auth;"@";""],                                    //protocol & if present auth (with @)
  x[`host],$[count x`path;x`path;"/"],                                              //host & path
  $[99=type x`query;"?",enc x`query;""];                                            //if there's a query, encode & append
  }

// @kind function
// @category private
// @fileoverview return URL as a string
// @param x {string|symbol|#hsym} URL
// @return {string} URL
sturl:{(":"=first x)_x:$[-11=type x;string;]x}

// @kind function
// @category private
// @fileoverview return URL as an hsym
// @param x {string|symbol|#hsym} URL
// @return {#hsym} URL
hsurl:{`$":",sturl x}

// @kind function
// @category private
// @fileoverview URI escaping for non-safe chars, RFC-3986
// @param x {string} URL
// @return {string} URL
hu:.h.hug .Q.an,"-.~"

// @kind function
// @category private
// @fileoverview encode a KDB dictionary as a URL encoded string
// @param d {dict} kdb dictionary to encode
// @return {string} URL encoded string
enc:{[d]
  k:key d;v:value d;                                                                //split dictionary into keys & values
  v:enlist each .url.hu each {$[10=type x;x;string x]}'[v];                         //string any values that aren't stringed,escape any chars that need it
  k:enlist each $[all 10=type each k;k;string k];                                   //if keys are strings, string them
  :"&" sv "=" sv' k,'v;                                                             //return urlencoded form of dictionary
  }

// @kind function
// @category private
// @fileoverview decode a URL encoded string to a KDB dictionary
// @param x {string} URL encoded string
// @return {dict} kdb dictionary to encode
dec:{[x]
  :(!/)"S=&"0:.h.uh ssr[x;"+";" "];                                                 //parse incoming request into dict, replace escaped chars
  }

\d .

\d .cookie

// @kind data
// @category public
// @fileoverview storage for cookies
jar:([host:();path:();name:()] val:();expires:`datetime$();maxage:`long$();secure:`boolean$();httponly:`boolean$();samesite:`$())

// @kind function
// @category public
// @fileoverview Add or update a cookie in the jar
// @param h {string} hostname on which to apply cookie
// @param c {string} cookie string
// @return {null}
addcookie:{[h;c]
  d:(!). "S=;"0:c;                                                                  //parse cookie into dict
  n:string first key d;v:first value d;                                             //extract cookie name & value
  d:lower[key d]!value d;                                                           //make all keys lower case
  r:`host`path`name`val!(".",h;d[`path],"*";n;v);                                   //build up record
  if[`domain in key d;r[`host]:"*.",d`domain];                                      //if domain in cookie, use it for host
  r[`expires]:"Z"$" "sv@[;1 2]" "vs d`expires;                                      //parse expiration date & time
  r[`maxage]:"J"$d`$"max-age";                                                      //TODO calculate expires from maxage
  r[`secure]:`secure in key d;                                                      //check if Secure attribute is set
  r[`httponly]:`httponly in key d;                                                  //check if HttpOnly attribute is set
  r[`samesite]:`$d`samesite;                                                        //check if SameSite attribute is set
  `.cookie.jar upsert enlist r;                                                     //add cookie to the jar
  }

// @kind function
// @category private
// @fileoverview Get stored cookie(s) relevant to current query
// @param q {dict} query object
// @return {string} cookie(s)
getcookies:{[q]
  h:q`host;p:q`path;pr:q`protocol;                                                  //extact necessary components
  h:".",h;                                                                          //prevent bad tailmatching
  t:select from .cookie.jar where h like/:host,p like/:path,(expires>.z.t)|null expires;  //select all cookies that apply
  if[not pr~"https://";t:delete from t where secure];                               //delete HTTPS only cookies if not HTTPS request
  :"; "sv"="sv'flip value exec name,val from t;                                     //compile cookies into string
  }

// @kind function
// @category private
// @fileoverview Add stored cookie(s) relevant to current query
// @param q {dict} query object
// @return {dict} query objeect with added cookies
addcookies:{[q]
  if[count c:getcookies[q`url];q[`headers;`Cookie]:c];
  :q;
  }

// @kind function
// @category public
// @fileoverview Read a Netscape/cURL format cookiejar
// @param f {string|symbol|#hsym} filename
// @return {table} cookie jar
readjar:{[f]
  j:read0 .url.hsurl f;                                                             //get hsym of input file & read
  j:j where not ("#"=first'[j])|0=count'[j];                                        //remove comments & empty lines
  t:flip`host`tailmatch`path`secure`expires`name`val!("*S*SJ**";"\t")0:j;           //convert to a table
  t:update host:{"*.",x}'[host] from t where tailmatch=`TRUE;                       //implement tailmatching
  t:update path:{x,"*"}'[path] from t;                                              //implement path matching
  t:update secure:secure=`TRUE from t;                                              //convert secure to boolean
  t:update expires:?[0=expires;0Nz;`datetime$`timestamp$1970.01.01D00+1e9*expires] from t; //calculate expiry
  :delete tailmatch from update httponly:0b,maxage:0Nj,samesite:` from t;           //add extra fields for reQ cookiejar
  }

// @kind function
// @category public
// @fileoverview Write a Netscape/cURL format cookiejar
// @param f {string|symbol|#hsym} filename
// @param j {table} cookie jar
// @return {#hsym} cookie jar filename
writejar:{[f;j]
  t :"# Netscape HTTP Cookie File\n";                                               //make file header (copy cURL)
  t,:"# https://curl.haxx.se/docs/http-cookies.html\n";
  t,:"# This file was generated by reQ! Edit at your own risk.\n\n";
  t,:"\n"sv 1_"\t"0:select                                                          //convert to tab delimited & drop headers
       {("."=first x)_x}'[except\:[host;"*"]],
       `FALSE`TRUE "*"=first'[host],
       except\:[path;"*"],
       `FALSE`TRUE secure,
       ?[null expires;0;`long$1e-9*(`timestamp$expires)-1970.01.01D00:00],          //convert expires back to epoch time
       name,
       val 
     from j;
  :.url.hsurl[f] 0: "\n"vs t;                                                       //write to file
  }

\d .

\d .b64

// @kind function
// @category public
// @fileoverview base64 encode a string. Where available, defaults to .Q.btoa built-in
// @param x {string} string to be encoded
// @return {string} encoded string
enc:{(neg[c] _ .Q.b6 0b sv' 00b,/:6 cut raze (0b vs'`byte$x),(8*c)#0b),(c:neg[count x]mod 3)#"="}
enc:@[value;`.Q.btoa;{[x;y]x}enc]

// @kind function
// @category public
// @fileoverview base64 decode a string
// @param x {string} base64 string to be decoded
// @return {string} decoded string
dec:{(`char$0b sv'8 cut raze 2_'0b vs'`byte$.Q.b6?x) except "\000"}

\d .

\d .status

// @kind function
// @category private
// @fileoverview get status "class" from status code, header dict or return object
// @param x {int|dict|(dict;string)} status code, header dict or return object
// @return {int} status class
class:{c:div[;100];$[0=type x;.z.s[first x];99=type x;c x`status;c x]}              //get class from status code, header dict or return object

/TODO: add dict of status codes

\d .

\d .req

// @kind data
// @category variable
// @fileoverview Flag for verbose mode
VERBOSE:@[value;`.req.VERBOSE;0i];                                                  //default to non-verbose output

// @kind data
// @category variable
// @fileoverview Flag for parsing output to q datatypes
PARSE:@[value;`.req.PARSE;1b];                                                      //default to parsing output

// @kind data
// @category variable
// @fileoverview Flag for signalling on HTTP errors
SIGNAL:@[value;`.req.SIGNAL;1b];                                                    //default to signalling for HTTP errors

// @kind data
// @category variable
// @fileoverview Default headers added to all HTTP requests
def:(!/) flip 2 cut (                                                               //default headers
  "Connection";     "Close";
  "User-Agent";     "kdb+/",string .Q.k;
  "Accept";         "*/*"
  )
if[.z.K>=3.7;def["Accept-Encoding"]:"gzip"];                                        //accept gzip compressed responses on 3.7+
query:`method`url`hsym`path`headers`body`bodytype!()                                //query object template

// @kind data
// @category variable
// @fileoverview Dictionary with Content-Types
ty:@[.h.ty;`form;:;"application/x-www-form-urlencoded"]                             //add type for url encoded form, used for slash commands
ty:@[ty;`json;:;"application/json"]                                                 //add type for JSON (missing in older versions of q)

// @kind data
// @category variable
// @fileoverview Dictionary with decompress functions for Content-Encoding types
decompress:()!()
decompress[enlist"gzip"]:-35!

// @kind function
// @category private
// @fileoverview Applies proxy if relevant
// @param u {dict} URL object
// @return {dict} Updated URL object
proxy:{[u]
  p:(^/)`$getenv`$(floor\)("HTTP";"NO"),\:"_PROXY";                                 //check HTTP_PROXY & NO_PROXY env vars, upper & lower case - fill so p[0] is http_, p[1] is no_
  t:max(first ":"vs u[`url]`host)like/:{(("."=first x)#"*"),x}each"," vs string p 1; //check if host is in NO_PROXY env var
  t:not null[first p]|t;                                                            //check if HTTP_PROXY is defined & host isn't in NO_PROXY
  :$[t;@[;`proxy;:;p 0];]u;                                                         //add proxy to URL object if required
  }

// @kind function
// @category private
// @fileoverview Convert headers to strings & add authorization and Content-Length
// @param q {dict} query object
// @return {dict} Updated query object
addheaders:{[q]
  d:.req.def;
  if[count q[`url;`auth];d[$[`proxy in key q;"Proxy-";""],"Authorization"]:"Basic ",.b64.enc q[`url;`auth]];
  if[count q`body;d["Content-Length"]:string count q`body];                         //if payload, add length header
  d,:$[11=type k:key q`headers;string k;k]!value q`headers;                         //get headers dict (convert keys to strings if syms), append to defaults
  :@[q;`headers;:;d];
  }

// @kind function
// @category private
// @fileoverview Convert a KDB dictionary into HTTP headers
// @param d {dict} dictionary of headers
// @return {string} string HTTP headers
enchd:{[d]
  k:2_@[k;where 10<>type each k:(" ";`),key d;string];                              //convert non-string keys to strings
  v:2_@[v;where 10<>type each v:(" ";`),value d;string];                            //convert non-string values to strings
  :("\r\n" sv ": " sv/:flip (k;v)),"\r\n\r\n";                                      //encode headers dict to HTTP headers
  }

// @kind function
// @category private
// @fileoverview Construct full HTTP query string from query object
// @param q {dict} query object
// @return {string} HTTP query string
buildquery:{[q]
  r:string[q`method]," ",q[`url;`path]," HTTP/1.1\r\n",                             //method & endpoint TODO: fix q[`path] for proxy use case
  "Host: ",q[`url;`host],$[count q`headers;"\r\n";""],                              //add host string
       enchd[q`headers],                                                            //add headers
       $[count q`body;q`body;""];                                                   //add payload if present
  :r;                                                                               //return complete query string
  }

// @kind function
// @category private
// @fileoverview Split HTTP response into headers & dict
// @param r {string} raw HTTP response
// @return {(dict;string;string)} (response header;response body;raw headers)
formatresp:{[r]
  p:(0,4+first r ss 4#"\r\n") cut r;                                                //split response headers & body
  rh:p 0;                                                                           //keep raw headers to return as text
  p:@[p;0;"statustext:",];                                                          //add key for status text line
  d:trim enlist[`]_(!/)("S:\n")0:p[0]except"\r";                                    //create dictionary of response headers
  d:lower[key d]!value d;                                                           //make headers always lower case
  d[`status]:"I"$(" "vs r)1;                                                        //add status code
  if[(`$"content-encoding")in key d;
      p[1]:.req.decompress[d`$"content-encoding"]p[1];                              //if compressed, decompress body based on content-encoding
    ];
  :(d;p[1];rh);                                                                     //return header dict, reponse body, raw headers string
  }

// @kind function
// @category private
// @fileoverview Signal if not OK status, return unchanged response if OK
// @param v {boolean} verbose flag
// @param x {(dict;string)} HTTP response object
// @return {(dict;string)} HTTP response object
okstatus:{[v;x]
  if[not[.req.SIGNAL]|v|x[0][`status] within 200 299;:x];                           //if signalling disabled, in verbose mode or OK status, return
  'string x[0]`status;                                                              //signal if bad status FIX: handle different status codes - descriptive signals
  }

// @kind function
// @category public
// @fileoverview Send an HTTP request
// @param m {symbol} HTTP method/verb
// @param u {symbol|string|#hsym} URL
// @param hd {dict} dictionary of custom HTTP headers to use
// @param p {string} payload/body (for POST requests)
// @param v {boolean} verbose flag
// @return {(dict;string)} HTTP response (headers;body)
send:{[m;u;hd;p;v]
  q:@[.req.query;`method`url`headers`body;:;(m;.url.parse0[0]u;hd;p)];              //parse URL into URL object & build query
  if[a:count q[`url]`auth;.auth.setcache . q[`url]`host`auth];                      //cache credentials if set
  if[not a;q[`url;`auth]:.auth.getcache q[`url]`host];                              //retrieve cached credentials if not set
  q:proxy q;                                                                        //check if we need to use proxy & get proxy address
  /nu:$[@[value;`.doh.ENABLED;0b];.doh.resolve;]u;                                   //resolve URL via DNS-over-HTTPS if enabled
  hs:.url.hsurl`$raze q ./:enlist[`url`protocol],$[`proxy in key q;1#`proxy;enlist`url`host]; //get hostname as handle
  q:.cookie.addcookies[q];                                                          //add cookie headers
  q:addheaders[q];                                                                  //get dictionary of HTTP headers for request
  r:hs d:buildquery[q];                                                             //build query and execute
  if[v;neg[`int$v]"-- REQUEST --\n",string[hs],"\n",d];                             //if verbose, log request
  r:formatresp r;                                                                   //format response to headers & body
  if[v;neg[`int$v]"-- RESPONSE --\n",r[2],"\n\n",r[1],("\n"<>last r[1])#"\n"];      //if verbose, log response
  if[(sc:`$"set-cookie") in k:key r 0;                                              //check for Set-Cookie headers
      .cookie.addcookie[q[`url;`host]]'[value[r 0]where k=sc]];                     //set any cookies necessary
  if[r[0][`status]=401;:.z.s[m;.auth.getauth[r 0;u];hd;p;v]];                       //if unauthorised prompt for user/pass FIX:should have some counter to prevent infinite loops
  if[.status.class[r] = 3;                                                          //if status is 3XX, redirect
      lo:$["/"=r[0][`location]0;.url.format[`protocol`auth`host#q`url],1_r[0]`location;r[0]`location]; //detect if relative or absolute redirect
     :.z.s[m;lo;hd;p;v]];                                                           //perform redirections if needed
  :r;
  }

// @kind function
// @category private
// @fileoverview Parse to kdb object based on Content-Type header. Only supports JSON currently
// @param r {(dict;string)} HTTP respone
// @return {any} Parsed response
parseresp:{[r]
  / TODO - add handling for other data types? /
  if[not .req.PARSE;:2#r];                                                          //if parsing disabled, return "raw" response (incl. headers dict)
  f:$[(`j in key`)&r[0][`$"content-type"]like .req.ty[`json],"*";.j.k;::];          //check for JSON, parse if so
  :@[f;r[1];r[1]];                                                                  //error trap parsing, return raw if fail
  }

// @kind function
// @category public
// @fileoverview Send an HTTP GET request
// @param x {symbol|string|#hsym} URL
// @param y {dict} dictionary of custom HTTP headers to use
// @return {(dict;string)|any} HTTP response (headers;body), or parsed if JSON
// @qlintsuppress RESERVED_NAME
.req.get:{parseresp okstatus[.req.VERBOSE] send[`GET;x;y;();.req.VERBOSE]}

// @kind function
// @category public
// @fileoverview Send an HTTP GET request (simple, no custom headers)
// @param x {symbol|string|#hsym} URL
// @return {(dict;string)|any} HTTP response (headers;body), or parsed if JSON
.req.g:.req.get[;()!()]

// @kind function
// @category public
// @fileoverview Send an HTTP POST request
// @param x {symbol|string|#hsym} URL
// @param y {dict} dictionary of custom HTTP headers to use
// @param z {string} body for HTTP request
// @return {(dict;string)|any} HTTP response (headers;body), or parsed if JSON
.req.post:{parseresp okstatus[.req.VERBOSE] send[`POST;x;y;z;.req.VERBOSE]}

// @kind function
// @category public
// @fileoverview Send an HTTP DELETE request
// @param x {symbol|string|#hsym} URL
// @param y {dict} dictionary of custom HTTP headers to use
// @param z {string} body for HTTP request
// @return {(dict;string)|any} HTTP response (headers;body), or parsed if JSON
// @qlintsuppress RESERVED_NAME
.req.delete:{parseresp okstatus[.req.VERBOSE] send[`DELETE;x;y;z;.req.VERBOSE]}

// @kind function
// @category public
// @fileoverview Send an HTTP DELETE request, no body
// @param x {symbol|string|#hsym} URL
// @param y {dict} dictionary of custom HTTP headers to use
// @return {(dict;string)|any} HTTP response (headers;body), or parsed if JSON
.req.del:.req.delete[;;()]

\d .

\d .auth

// @kind function
// @category private
// @fileoverview *EXPERIMENTAL* prompt for authorization if requested
// @param h {dict} HTTP response headers
// @param u {string|symbol|#hsym} URL
// @return {string} updated URL with supplied credentials
getauth:{[h;u] /h-headers,u-URL
  /* prompt for user & pass when site requests basic auth */
  h:upper[key h]!value h;                                                           //upper case header names
  if[not h[`$"www-authenticate"] like "Basic *";'"unsupported auth challenge"];     //check it needs basic auth
  -1"Site requested basic auth\nWARNING: user & pass will show in plain text\n";    //warn user before they type pass
  1"User: ";s:read0 0;                                                              //get username
  1"Pass: ";p:read0 0;                                                              //get password
  :.url.format @[.url.parse0[0b] u;`auth;:;s,":",p];                                //update URL with supplied username & pass
  }

// @kind data
// @category public
// @fileoverview storage for basic auth credential cache
cache:([host:`$()]auth:();expires:`timestamp$())

// @kind function
// @category private
// @fileoverview cache auth string for a given host
// @param host {string} hostname
// @param auth {string} auth string in format "user:pass"
// @return null
setcache:{[host;auth]cache[`$host]:`auth`expires!(auth;.z.p+0D00:15:00)}

// @kind function
// @category private
// @fileoverview get cached auth string for a given host
// @param hst {string} hostname
// @return {string} cached auth string
getcache:{[hst]
  r:exec first auth from cache where host=`$hst,expires>.z.p;
  if[count r;:r];
  if[netrcenabled;:readnetrc hst];
  :();
 }

// @kind data
// @category public
// @fileoverview boolean flag to determine whether to use ~/.netrc by default
netrcenabled:not()~key .os.hfile`.netrc

// @kind data
// @category public
// @fileoverview location of .netrc file, by default ~/.netrc
netrclocation:.os.hfile`.netrc

// @kind function
// @category private
// @fileoverview retrieve login from .netrc file
// @param host {string} hostname to get login for
// @return {string} auth string in format "user:pass"
readnetrc:{[host]
  i:.os.read netrclocation;
  t:(uj/){enlist(!/)"S*"$flip x} each (where i like "machine *") cut " " vs/:i;
  if[0=count t:select from t where machine like host;:()];
  :":"sv first[t]`login`password;
 }

\d .

\d .req

// @kind function
// @category private
// @fileoverview Generate boundary marker
// @param x {any} Unused
// @return {string} Boundary marker
gb:{(24#"-"),16?.Q.an}
// @kind function
// @category private
// @fileoverview Build multi-part object
// @param b {string} boundary marker
// @param d {dict} headers (incl. file to be multiparted)
// @return {string} Multipart form
mult:{[b;d] "\r\n" sv mkpt[b]'[string key d;value d],enlist"--",b,"--"}             //build multipart

// @kind function
// @category private
// @fileoverview Create one part for a multipart form
// @param b {string} boundary marker
// @param n {string} name for form part
// @param v {string} value for form part
// @return {string[]} multipart form
mkpt:{[b;n;v]
  f:-11=type v;                                                                     //check for file
  t:"";                                                                             //placeholder for Content-Type
  if[f;t:"Content-Type: ",$[0<count t:.h.ty last` vs`$.url.sturl v;t;"application/octet-stream"],"\n"];     //get content-type for part
  r :"--",b,"\n";                                                                   //opening boundary
  r,:"Content-Disposition: form-data; name=\"",n,"\"",$[f;"; filename=",1_string v;""],"\n";
  r,:t,"\n",$[f;`char$read1 v;v];                                                   //insert file contents or passed value
  :r;
  }

// @kind function
// @category private
// @fileoverview Convert a q dictionary to a multipart form
// @param d {dict} kdb dictionary to convert to form
// @return {(dict;string)} (HTTP headers;body) to give to .req.post
multi:{[d]
  b:gb[];                                                                           //get boundary value
  m:mult[b;d];                                                                      //make multipart form from dictionary
  :((1#`$"Content-Type")!enlist"multipart/form-data; boundary=",b;m);               //return HTTP header & multipart form
  }

postmulti:{post[x] . multi y}                                                       //send HTTP POST report with multipart form

\d .

