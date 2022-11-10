\d .teams

hooks:exec channel!hook from ("S*";enlist",")0:`:config/teamschannels.csv
template:(`$("@context";"@type"))!("https://schema.org/extensions";"MessageCard");
msg:{[url;title;msg].Q.hp[hsym`$url;.h.ty`json].j.j template,`title`text!(title;msg)}
