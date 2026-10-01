let
    Origen = Ventas_Limpia,
    #"Otras columnas quitadas" = Table.SelectColumns(Origen,{"Country"}),
    #"Duplicados quitados" = Table.Distinct(#"Otras columnas quitadas"),
    #"Filas ordenadas" = Table.Sort(#"Duplicados quitados",{{"Country", Order.Ascending}}),
    #"Índice agregado" = Table.AddIndexColumn(#"Filas ordenadas", "ID_Pais", 1, 1, Int64.Type)
in
    #"Índice agregado"