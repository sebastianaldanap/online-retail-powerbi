let
    Origen = Table.Combine({Ventas_2009_2010, Ventas_2010_2011}),
    #"Tipo cambiado" = Table.TransformColumnTypes(Origen,{{"Invoice", type text}, {"StockCode", type text}, {"Description", type text}, {"Quantity", Int64.Type}, {"InvoiceDate", type datetime}, {"Price", type number}, {"Customer ID", Int64.Type}, {"Country", type text}}),
    #"Texto recortado" = Table.TransformColumns(#"Tipo cambiado",{{"Invoice", Text.Trim, type text}, {"StockCode", Text.Trim, type text}, {"Description", Text.Trim, type text}, {"Country", Text.Trim, type text}}),
    #"Texto en mayúsculas" = Table.TransformColumns(#"Texto recortado",{{"StockCode", Text.Upper, type text}}),
    #"Columna condicional agregada" = Table.AddColumn(#"Texto en mayúsculas", "Tipo_Transaccion", each if Text.StartsWith([Invoice], "C") then "Cancelacion" else if [Quantity] < 0 then "Ajuste" else "Venta"),
    #"Columna condicional agregada1" = Table.AddColumn(#"Columna condicional agregada", "Categoria_Item", each if [StockCode] = "POST" then "No_Producto" else if [StockCode] = "DOT" then "No_Producto" else if [StockCode] = "M" then "No_Producto" else if [StockCode] = "m" then "No_Producto" else if [StockCode] = "C2" then "No_Producto" else if [StockCode] = "C3" then "No_Producto" else if [StockCode] = "D" then "No_Producto" else if [StockCode] = "BANK CHARGES" then "No_Producto" else if [StockCode] = "S" then "No_Producto" else if [StockCode] = "ADJUST" then "No_Producto" else if [StockCode] = "ADJUST2" then "No_Producto" else if [StockCode] = "AMAZONFEE" then "No_Producto" else if [StockCode] = "TEST001" then "No_Producto" else if [StockCode] = "TEST002" then "No_Producto" else if [StockCode] = "CRUK" then "No_Producto" else if [StockCode] = "GIFT" then "No_Producto" else if Text.StartsWith([StockCode], "gift_") then "No_Producto" else "Producto"),
    #"Personalizada agregada" = Table.AddColumn(#"Columna condicional agregada1", "Importe", each [Quantity] * [Price]),
    #"Columna condicional agregada2" = Table.AddColumn(#"Personalizada agregada", "Tiene_Precio", each if [Price] = 0 then "No" else "Si"),
    #"Tipo cambiado1" = Table.TransformColumnTypes(#"Columna condicional agregada2",{{"Tipo_Transaccion", type text}, {"Categoria_Item", type text}, {"Importe", type number}, {"Tiene_Precio", type text}}),
    #"Valor reemplazado" = Table.ReplaceValue(#"Tipo cambiado1",null,0,Replacer.ReplaceValue,{"Customer ID"}),
    #"Columna duplicada" = Table.DuplicateColumn(#"Valor reemplazado", "InvoiceDate", "Fecha"),
    #"Tipo cambiado2" = Table.TransformColumnTypes(#"Columna duplicada",{{"Fecha", type date}}),
    #"Columna duplicada1" = Table.DuplicateColumn(#"Tipo cambiado2", "InvoiceDate", "Hora"),
    #"Tipo cambiado3" = Table.TransformColumnTypes(#"Columna duplicada1",{{"Hora", type time}}),
    #"Filas filtradas" = Table.SelectRows(#"Tipo cambiado3", each not Text.StartsWith([Invoice], "A")),
    #"Tipo cambiado4" = Table.TransformColumnTypes(#"Filas filtradas",{{"Customer ID", Int64.Type}})
in
    #"Tipo cambiado4"