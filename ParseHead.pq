[func=(table,num,optional delim,optional fill)=>
   [
    lst = List.Buffer(Table.ToColumns(Table.TransformColumns(Table.Range(table,0,num),{},Text.From))), 
    delim = if delim=null then " " else delim,
    f=(x,y)=>List.Accumulate(   List.Zip({x,y}),
                                [i=false,j={}],
                                (s,c)=>[i=s[i]=true or c{0}<>null,j=if i then s[j]&{c{0}} else s[j]&{c{0}??c{1}}]
                            )[j],
    g=(x)=>if fill=null then Text.Combine(x,delim) else Text.Combine(List.ReplaceValue(x,null,fill,Replacer.ReplaceValue),delim), 
    gen = List.Generate(    ()=>[i=0,l=lst{i},o=l],
                            (x)=>x[i]<List.Count(lst),
                            (x)=>[i=x[i]+1,l=lst{i},o=f(l,x[o])],
                            (x)=>g(x[o])
                        ),
    out = Table.RenameColumns(Table.Range(table,num),List.Zip({Table.ColumnNames(table),gen}))
    ][out],
    typ = type function (
                table as (type table meta [Documentation.FieldCaption = "исходная таблица"]),
                num as (type number meta [Documentation.FieldCaption = "число строк для анализа шапки"]),
                optional delim as (type text meta [Documentation.FieldCaption = "(необязательно) разделитель для названий столбцов разных уровней"]),
                optional fill as (type text meta [Documentation.FieldCaption = "(необязательно) строковое значение, подставляемое вместо отсутствующего заголовка"])
                         )           
                as table meta [
                    Documentation.Name = "ParsHead", 
                    Documentation.Description = "функция анализирует первые несколько строк таблицы <i><b>table</b></i>, указанных в параметре  <i><b>num</b></i>, осуществляет заполнение ячеек (по принципу ""fillrigth"") при условии, что ячейки в текущем столбце выше пусты, далее по столбцам идёт объединение текста с использованием в качестве разделителя параметра  <i><b>delim</b></i>. Опционально четвертый параметр <i><b>fill</b></i> позволяет задать строковое значение, которое будет использовано для заголовков нижних уровней в случае их отсутствия в данном столбце "
                    ],
    res=Value.ReplaceType(func,typ)][res]
