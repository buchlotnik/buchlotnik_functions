(optional year as number)=>[
f=(x)=>{Date.From(Text.TrimEnd(Text.Combine({year}&List.FirstN(x,2)),"*")),x{2}},
year = Text.From(if year=null then Date.Year(DateTime.LocalNow()) else year),
from = Binary.Buffer(Web.Contents("http://www.consultant.ru/law/ref/calendar/proizvodstvennye/"&(if year="2020" then "2020b" else year))),
html = Html.Table(from,{{"m","th"},{"d","td"},{"t","td",(x)=>x[Attributes][class]}},[RowSelector="th.month,td[class]"]),
tbl = Table.SelectRows(Table.FillDown(html,{"m"}),(x)=>x[t]<>null and x[t]<>"inactively"),   
to = Table.FromList(Table.ToList(tbl,f),(x)=>x,type table [Date=date,DateType=text])][to]
