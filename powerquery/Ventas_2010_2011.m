let
  Origen = Excel.Workbook(File.Contents("C:\Users\Sebastian\OneDrive\Desktop\Especialización Data Analyst\3. Power BI\Proyecto_Final\online-retail-powerbi\dataset\datos_online_retail_II.xlsx"), null, true),
  #"Navegación 1" = Origen{[Item = "Year 2010-2011", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"Description", type text}, {"Quantity", Int64.Type}, {"InvoiceDate", type datetime}, {"Price", type number}, {"Customer ID", Int64.Type}, {"Country", type text}}, "es"),
    #"Filas filtradas" = Table.SelectRows(#"Tipo de columna cambiado", each [InvoiceDate] > #datetime(2010, 12, 10, 0, 0, 0))
in
    #"Filas filtradas"