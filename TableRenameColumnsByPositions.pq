[func =(table,list) =>
    [   a = List.Buffer(Table.ColumnNames(table)),
        b = List.Count(a),
        c = (x) =>{a{if x{0}>0 then x{0}-1 else b+x{0}},x{1}},
        d = if list{0} is list then List.Transform(list,c) else c(list),
        e = Table.RenameColumns(table,d)
    ][e],
typ = type function (
                table as (type table meta [Documentation.FieldCaption = "исходная таблица"]),
                list as (type list meta [Documentation.FieldCaption = "параметры переименования"])
                         )           
                as table meta [ 
                                Documentation.Name = "TableRenameColumnsByPositions> (@buchlotnik)",
                                Documentation.LongDescription = "Функция переименовывает столбцы таблицы  по их номеру. Параметры переименования задаются в виде списка {номер, новое название} либо списка списков {{номер1, новое название1},{номер2, новое название2}}. Положительное значение номера задает нумерацию с начала таблицы, отрицательное - с конца.",
                                Documentation.Examples = {
                                    [Description = "переименовать первый столбец", Code = "=TableRenameColumnsByPositions(#table({""a"",""b"",""c""},{}),{1,""первый""})",Result="#table({""первый"",""b"",""c""},{})"], 
                                    [Description = "перименовать первый с конца столбец", Code =  "=TableRenameColumnsByPositions(#table({""a"",""b"",""c""},{}),{-1,""первый с конца""})",Result="#table({""a"",""b"",""первый с конца""},{})"], 
                                    [Description = "переименовать первый и последний столбцы", Code = "=TableRenameColumnsByPositions(#table({""a"",""b"",""c""},{}),{{1,""первый""},{-1,""последний""}})",Result="#table({""первый"",""b"",""последний""},{})"]
                                    }        
                                ],
    result = Value.ReplaceType(func,typ)
][result]
