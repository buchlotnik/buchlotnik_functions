[
    readme="Dynamic Dicionary Library (DDL) @buchlotnik",

    AddKey=(tbl,nms)=>Table.AddColumn(tbl,"key",(x)=>Text.Combine(Record.ToList(Record.SelectFields(x,nms)),"|")),
    MakeDict=(tbl,nms,vnm)=>((a)=>Record.FromList(Table.Column(a,vnm),Table.Column(a,"key")))(AddKey(tbl,nms)),
    MakeDictDeep=(tbl)=>[
            init=[] ,
            slct=(x)=>x,
            lst=List.Buffer(Table.ToList(tbl,(x)=>x)),
            n=List.Count(lst),
            func=(s,c)=>[newdict=SetDeep(s,List.RemoveLastN(c,1),List.Last(c))],
            step=(optional x)=>[
                i=if x=null then 0 else x[i]+1,
                dict=if x=null then init else x[newdict],
                cur=lst{i}?,
                new=func(dict,cur),
                out=[i=i]&new][out],
            gen=List.Generate(step,(x)=>x[i]<n,step,slct),
            res = List.Last(gen)[newdict]][res],
    
    
    Get=(rec,key)=>Record.FieldOrDefault(rec,key,0),

   GetDeep=(rec,lst)=>((a)=>if a=null then 0 else a)(List.Accumulate(lst,rec,(s,c)=>Record.FieldOrDefault(s,c))),

    Set=(rec,key,val)=>
        if Record.HasFields(rec,key)
        then Record.TransformFields(rec,{key,(old)=>val})
        else Record.AddField(rec,key,val),

   SetDeep = (rec as record, lst as list,val) =>
         if List.Count(lst) = 1 then
                if Record.HasFields(rec,lst{0}) 
                then Record.TransformFields(rec,{lst{0},(x)=>val})
                else Record.AddField(rec,lst{0},val)
        else
                if Record.HasFields(rec,lst{0}) 
                then Record.TransformFields(rec,{lst{0},(x) => @SetDeep(x,List.Skip(lst),val)})
                else Record.AddField(rec,lst{0},CreatePath(List.Skip(lst),val)),

    Update=(rec,key,delta)=>
        if Record.HasFields(rec,key)
        then Record.TransformFields(rec,{key,(old)=>old+delta})
        else Record.AddField(rec,key,delta),
    
    UpdateDeep = (rec as record, lst as list,val) =>
         if List.Count(lst) = 1 then
                if Record.HasFields(rec,lst{0}) 
                then Record.TransformFields(rec,{lst{0},(x)=>x+val})
                else Record.AddField(rec,lst{0},val)
        else
                if Record.HasFields(rec,lst{0}) 
                then Record.TransformFields(rec,{lst{0},(x) => @UpdateDeep(x,List.Skip(lst),val)})
                else Record.AddField(rec,lst{0},CreatePath(List.Skip(lst),val)),
    

    Run=(tbl,func,optional init,optional slct)=>[
            init=if init=null then [] else init,
            slct=if slct=null then (x)=>x else slct,
            lst=List.Buffer(Table.ToRecords(tbl)),
            n=List.Count(lst),
            step=(optional x)=>[
                i=if x=null then 0 else x[i]+1,
                dict=if x=null then init else x[newdict],
                cur=lst{i}?,
                new=func(dict,cur),
                out=[i=i]&new][out],
            gen=List.Generate(step,(x)=>x[i]<n,step,slct),
            to=Table.FromRecords(gen)][to],
            
    

    CreatePath=(lst as list,val) =>Record.AddField([],lst{0},if List.Count(lst) = 1 then val else @CreatePath(List.Skip(lst),val))
]
