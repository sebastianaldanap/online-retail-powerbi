let
    Origen = Ventas_Limpia,
    #"Columnas quitadas" = Table.RemoveColumns(Origen,{"Description", "InvoiceDate"}),
    #"Consultas combinadas" = Table.NestedJoin(#"Columnas quitadas", {"Country"}, Dim_Pais, {"Country"}, "Dim_Pais", JoinKind.LeftOuter),
    #"Se expandió Dim_Pais" = Table.ExpandTableColumn(#"Consultas combinadas", "Dim_Pais", {"ID_Pais"}, {"ID_Pais"}),
    #"Columnas quitadas1" = Table.RemoveColumns(#"Se expandió Dim_Pais",{"Country"})
in
    #"Columnas quitadas1"