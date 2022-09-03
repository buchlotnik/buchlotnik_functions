[   func = (ZIP, optional cp)=>
        [   ui16 = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger16, ByteOrder.LittleEndian),
            ui32 = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian),
            b = (x) => BinaryFormat.Binary(x),
            c = if cp is null then 866 else cp,
            f = (x) => try Binary.Decompress(x, Compression.Deflate) otherwise null,
            g = (x) => BinaryFormat.Transform(b(x),f),
            h = (x) => [head = BinaryFormat.Record([a = b(14), size=ui32, c=b(4), name=ui16, extra=ui16])(x),
                        body = BinaryFormat.Record( [ FileName = BinaryFormat.Text(head[name],c),
                                                  Extras   = b(head[extra]),
                                                  Content  = g(head[size]),
                                                  flag  = true])][body],
            iftrue = BinaryFormat.Choice(b(26),h),
            iffalse = BinaryFormat.Record([flag = false]),
            getfile = BinaryFormat.Choice(ui32, (x)=> if x = 67324752 then iftrue else iffalse, type binary),
            filelist = BinaryFormat.List(getfile, each [flag] = true)(ZIP),
            remove = List.RemoveLastN(filelist,1),
            to = Table.FromRecords(remove, type table [FileName = text, Content = binary])][to],
    typ = type function (
                ZIP as (type binary meta [Documentation.FieldCaption = "бинарное содержимое (zip,xlsx,docx,pptx и т.п.)"]),
                optional cp as (type number meta [Documentation.FieldCaption = "кодировка", Documentation.SampleValues = {866}])
                         )           
                as table meta [ 
                                Documentation.Name = "UnZip (@buchlotnik)",
                                Documentation.LongDescription = "Функция считывает содержимое zip-архива и возвращает таблицу с полями FileName - имя файла (с путём, если он в подпапке) и Content - бинарное содержимое конкретного файла. Кодировка требуется для корректного распознавания <b>не латинских</b> имён файлов (для офисных документов указывать необязательно), по умолчанию 866 - кодировка DOS <b>с поддержкой кириллицы</b>"        
                                ],
    result = Value.ReplaceType(func,typ)
][result]
