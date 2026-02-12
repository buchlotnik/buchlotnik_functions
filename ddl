[
    readme="Dynamic Dicionary Library (DDL) @buchlotnik",

    AddKey=(tbl,nms)=>Table.AddColumn(tbl,"key",(x)=>Text.Combine(Record.ToList(Record.SelectFields(x,nms)),"|")),

    ConsumeFIFO=(lst,val,valfield)=>[internalfunc=(lst,val,lstout)=>    
                                        if lst={} 
                                        then [  out=lstout, 
                                                stock={},
                                                gap=val] 
                                            else    if val<=Record.Field(lst{0},valfield) 
                                                    then [  out=lstout&{Record.TransformFields(lst{0},{valfield,(x)=>val})},
                                                            stock=(if val=Record.Field(lst{0},valfield) then{} else {Record.TransformFields(lst{0},{valfield,(x)=>x-val})})&List.Skip(lst),
                                                            gap=0]
                                                    else @internalfunc(List.Skip(lst),val-lst{0}[количество],lstout&{lst{0}}),
                                    res=internalfunc(lst,val,{})][res],

    CreatePath=(lst,val) =>Record.AddField([],lst{0},if List.Count(lst) = 1 then val else @CreatePath(List.Skip(lst),val)),
    
    Get=(rec,key)=>Record.FieldOrDefault(rec,key,0),

    GetDeep=(rec,lst, optional ifnull)=>((a)=>if a=null then (if ifnull=null then 0 else ifnull) else a)(List.Accumulate(lst,rec,(s,c)=>Record.FieldOrDefault(s,c))),

    MakeDict=(tbl,nms,vnm)=>((a)=>Record.FromList(Table.Column(a,vnm),Table.Column(a,"key")))(AddKey(tbl,nms)),

    MakeDictDeep=(tbl)=>Run(tbl,(s,c)=>[newdict=SetDeep(s,List.RemoveLastN(c,1),List.Last(c))],[],(x)=>x,true),

    MakeDictDeepFIFO=(tbl,grplst,dictQtyName,rowQtyName,optional metadataFieldNames)=>[
            nms=if metadataFieldNames=null then List.Buffer(List.RemoveMatchingItems(Table.ColumnNames(tbl),{rowQtyName})) else metadataFieldNames,
            gr= Table.Group(tbl,grplst,{"tmp",(x)=>
                [       stock=Table.TransformRows(x,(row)=>Record.AddField([],dictQtyName,Record.Field(row,rowQtyName))&[metadata=Record.SelectFields(row,nms)]),
                        queue={}]
                        }),
            result=MakeDictDeep(gr)][result],

    MoveDeep=(rec,pathfrom,pathto,val)=>UpdateDeep(UpdateDeep(rec,pathfrom,-val),pathto,val),

        ProcessFIFO=(dict,row,path,income,dictQtyName,rowQtyName,optional metadataFieldNames)=>
        
                [oldDict = GetDeep(dict,path,[stock={},queue={}]),
                nms= if metadataFieldNames=null then Record.FieldNames(row) else metadataFieldNames,  
                calc = if income then
                 [
                        queue=ConsumeFIFO(oldDict[queue],Record.Field(row,rowQtyName),dictQtyName),
                        new_queue=queue[stock],
                        gap=queue[gap],
                        new_stock=oldDict[stock]&(if gap>0 then {Record.AddField([],dictQtyName,gap)&[metadata=Record.SelectFields(row,nms)]} else {}),
                        
                        out=queue[out]
                ]
                else 
                [       
                        stock=ConsumeFIFO(oldDict[stock],Record.Field(row,rowQtyName),dictQtyName),
                        new_stock=stock[stock],
                        gap=stock[gap],
                        new_queue=oldDict[queue]&(if gap>0 then {Record.AddField([],dictQtyName,gap)&[metadata=Record.SelectFields(row,nms)]} else {}),
                        out=stock[out]
                ],
                result=[
                    oldStock=oldDict[stock],
                    oldQueue=oldDict[queue],
                    newStock=calc[new_stock],
                    newQueue=calc[new_queue],
                    outList=calc[out],
                    gap=calc[gap]
                ]][result],

        Run=(tbl,func,optional init,optional slct,optional dictonly)=>[
            init=if init=null then [] else init,
            slct=if slct=null then (x)=>x else slct,
            lst=List.Buffer(if dictonly=null then Table.ToRecords(tbl) else Table.ToList(tbl,(x)=>x)),
            n=List.Count(lst),
            step=(optional x)=>[
                i=if x=null then 0 else x[i]+1,
                dict=if x=null then init else x[newdict],
                cur=lst{i}?,
                new=func(dict,cur),
                out=[i=i]&new][out],
            gen=List.Generate(step,(x)=>x[i]<n,step,slct),
            to=if dictonly=null then Table.FromRecords(gen) else List.Last(gen)[newdict]][to],



    Set=(rec,key,val)=>
        if Record.HasFields(rec,key)
        then Record.TransformFields(rec,{key,(old)=>val})
        else Record.AddField(rec,key,val),

    SetDeep = (rec, lst,val) =>
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
    
    UpdateDeep = (rec, lst,val) =>
         if List.Count(lst) = 1 then
                if Record.HasFields(rec,lst{0}) 
                then Record.TransformFields(rec,{lst{0},(x)=> x+val})
                else Record.AddField(rec,lst{0},val)
        else
                if Record.HasFields(rec,lst{0}) 
                then Record.TransformFields(rec,{lst{0},(x) => @UpdateDeep(x,List.Skip(lst),val)})
                else Record.AddField(rec,lst{0},CreatePath(List.Skip(lst),val))
]
