(optional year as nullable number) =>
   [path = "http://www.consultant.ru/law/ref/calendar/proizvodstvennye/",
    yr = if year=null then Date.Year(DateTime.LocalNow()) else year, 
    from = Text.FromBinary(Web.Contents(path&Text.From(yr)&(if yr = 2020 then "b" else ""))),
    splt = List.Skip(Text.Split(from,"#(tab,tab,tab)<td class=")),
    lst=List.Zip({{1..12},splt}),
    f=(x)=>[a=Text.Split(x{1},"<td class="),
            b=List.Select(a,(x)=>not Text.Contains(x,"inactively")),
            c=List.Transform(b,(x)=>List.Range(Text.SplitAny(x,"><"),0,2))][c],
    g=(x,y)=>{#date(yr,x{0},Number.From(y{1})),Text.Remove(y{0},"""")},
    tr=List.TransformMany(lst,f,g),
    tbl=Table.FromList(tr,(x)=>x,type table [Date=date,DateType=text])][tbl]
