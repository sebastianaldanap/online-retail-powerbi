let
    Origen = Ventas_Limpia,
    #"Otras columnas quitadas" = Table.SelectColumns(Origen,{"Customer ID"}),
    #"Duplicados quitados" = Table.Distinct(#"Otras columnas quitadas"),
    #"Columna condicional agregada" = Table.AddColumn(#"Duplicados quitados", "Nombre_Cliente", each if [Customer ID] = 0 then "Cliente no identificado" else [Customer ID]),
    #"Personalizada agregada" = Table.AddColumn(#"Columna condicional agregada", "Nombre_Cliente_Final", each if [Customer ID] = 0 then "Cliente no identificado" else "Cliente " & Text.From([Customer ID])),
    #"Columnas quitadas" = Table.RemoveColumns(#"Personalizada agregada",{"Nombre_Cliente"}),
    #"Columnas con nombre cambiado" = Table.RenameColumns(#"Columnas quitadas",{{"Nombre_Cliente_Final", "Nombre_Cliente"}}),
    #"Filas ordenadas" = Table.Sort(#"Columnas con nombre cambiado",{{"Customer ID", Order.Ascending}}),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Filas ordenadas",{{"Customer ID", Int64.Type}, {"Nombre_Cliente", type text}})
in
    #"Tipo cambiado"