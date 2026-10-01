let
    FechaMin = List.Min(Fact_Ventas[Fecha]),
    FechaMax = List.Max(Fact_Ventas[Fecha]),
    FechaInicio = Date.StartOfYear(FechaMin),
    FechaFin = Date.EndOfYear(FechaMax),
    NumeroDias = Duration.Days(FechaFin - FechaInicio) + 1,
    ListaFechas = List.Dates(FechaInicio, NumeroDias, #duration(1,0,0,0)),
    TablaBase = Table.FromList(ListaFechas, Splitter.SplitByNothing(), {"Fecha"}),
    TipoFecha = Table.TransformColumnTypes(TablaBase, {{"Fecha", type date}}),
    AñoCol = Table.AddColumn(TipoFecha, "Año", each Date.Year([Fecha]), Int64.Type),
    NumMesCol = Table.AddColumn(AñoCol, "NúmeroMes", each Date.Month([Fecha]), Int64.Type),
    MesCol = Table.AddColumn(NumMesCol, "Mes", each Text.Proper(Date.MonthName([Fecha], "es-ES")), type text),
    TrimCol = Table.AddColumn(MesCol, "Trimestre", each "T" & Number.ToText(Date.QuarterOfYear([Fecha])), type text),
    AñoTrimCol = Table.AddColumn(TrimCol, "AñoTrimestre", each Number.ToText(Date.Year([Fecha])) & "-T" & Number.ToText(Date.QuarterOfYear([Fecha])), type text),
    AñoMesCol = Table.AddColumn(AñoTrimCol, "AñoMes", each Date.ToText([Fecha], "yyyy-MM"), type text),
    NumDiaSemCol = Table.AddColumn(AñoMesCol, "NúmeroDíaSemana", each Date.DayOfWeek([Fecha], Day.Monday) + 1, Int64.Type),
    DiaSemCol = Table.AddColumn(NumDiaSemCol, "DíaSemana", each Text.Proper(Date.DayOfWeekName([Fecha], "es-ES")), type text),
    DiaMesCol = Table.AddColumn(DiaSemCol, "NúmeroDíaMes", each Date.Day([Fecha]), Int64.Type),
    FinSemanaCol = Table.AddColumn(DiaMesCol, "EsFinDeSemana", each Date.DayOfWeek([Fecha], Day.Monday) >= 5, type logical),
    SemanaCol = Table.AddColumn(FinSemanaCol, "NúmeroSemana", each Date.WeekOfYear([Fecha]), Int64.Type)
in
    SemanaCol