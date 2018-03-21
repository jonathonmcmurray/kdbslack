\d .sm

baseurl:"http://api.smmry.com/?"                                                    //API url
token:first read0`:config/smtoken                                                   //API token

getsm:{[url]
  p:.post.urlencode`SM_API_KEY`SM_LENGTH`SM_URL!(token;5;.post.hu url);             //generate query string
  j:.j.k .Q.hg hsym`$baseurl,p;                                                     //query API & parse JSON
  :trim j`sm_api_content;                                                           //return summary
 }

f:{
  s:"Summary of ",x[`text],":\n>>>";                                                //include link & quote the summary
  s,:getsm x`text;                                                                  //join summary
  .slack.postase[s;x`channel_id;"summarybot";":computer:"];                         //post in chat
  :.slack.ok;                                                                       //suppress echoing of command in chat
 }

\d .

.cmd.sm:.sm.f
