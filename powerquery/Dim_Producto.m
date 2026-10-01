let
    Origen = Ventas_Limpia,
    #"Otras columnas quitadas" = Table.SelectColumns(Origen,{"StockCode", "Description", "Fecha"}),
    #"Columna condicional agregada" = Table.AddColumn(#"Otras columnas quitadas", "Tiene_Descripcion", each if [Description] = null then 0 else 1),
    #"Filas ordenadas1" = Table.Sort(#"Columna condicional agregada",{{"Tiene_Descripcion", Order.Descending}, {"Fecha", Order.Descending}}),
    #"Duplicados quitados1" = Table.Distinct(#"Filas ordenadas1", {"StockCode"}),
    #"Columnas quitadas" = Table.RemoveColumns(#"Duplicados quitados1",{"Fecha", "Tiene_Descripcion"})
in
    #"Columnas quitadas"