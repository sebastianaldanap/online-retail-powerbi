# Medidas DAX — Online Retail II

Todas las medidas viven en la tabla `_Medidas`. Se agrupan por categoría según la pregunta de negocio que resuelven.

## KPIs Generales

### Ingresos Netos
```dax
Ingresos Netos = 
CALCULATE(
    SUM(Fact_Ventas[Importe]),
    Fact_Ventas[Categoria_Item] = "Producto"
)
```
Suma de ventas menos cancelaciones, excluyendo cargos administrativos (envíos, comisiones, ajustes manuales).

### Nº Facturas
```dax
Nº Facturas = 
CALCULATE(
    DISTINCTCOUNT(Fact_Ventas[Invoice]),
    Fact_Ventas[Categoria_Item] = "Producto"
)
```
Conteo de facturas distintas de productos reales.

### Ticket Promedio
```dax
Ticket Promedio = 
DIVIDE(
    [Ingresos Netos],
    [Nº Facturas]
)
```
Ingreso promedio por factura.

### Unidades Vendidas
```dax
Unidades Vendidas = 
CALCULATE(
    SUM(Fact_Ventas[Quantity]),
    Fact_Ventas[Categoria_Item] = "Producto"
)
```
Unidades netas movidas (ventas menos cancelaciones).

## Cancelaciones

### Importe Bruto Vendido
```dax
Importe Bruto Vendido = 
CALCULATE(
    SUM(Fact_Ventas[Importe]),
    Fact_Ventas[Tipo_Transaccion] = "Venta"
)
```
Total vendido antes de restar cancelaciones. Base para calcular el % cancelado.

### Importe Cancelado
```dax
Importe Cancelado = 
CALCULATE(
    SUM(Fact_Ventas[Importe]),
    Fact_Ventas[Tipo_Transaccion] = "Cancelacion"
)
```
Monto cancelado (negativo por diseño).

### Importe Cancelado Abs
```dax
Importe Cancelado Abs = 
ABS(
    CALCULATE(
        SUM(Fact_Ventas[Importe]),
        Fact_Ventas[Tipo_Transaccion] = "Cancelacion",
        Fact_Ventas[Categoria_Item] = "Producto"
    )
)
```
Versión en positivo, filtrada solo a productos reales (excluye cargos administrativos). Usada en gráficos de barras.

### % Cancelado
```dax
% Cancelado = 
DIVIDE(
    -[Importe Cancelado],
    [Importe Bruto Vendido]
)
```
Proporción del valor vendido que termina cancelado.

## Segmentación RFM (Recencia, Frecuencia, Monto)

### Fecha Referencia RFM
```dax
Fecha Referencia RFM = MAX(Fact_Ventas[Fecha])
```
Fecha más reciente del dataset (9 dic 2011), usada como "hoy" para calcular recencia.

### Recencia (dias)
```dax
Recencia (dias) = 
VAR UltimaCompra = 
    CALCULATE(
        MAX(Fact_Ventas[Fecha]),
        Fact_Ventas[Tipo_Transaccion] = "Venta",
        Fact_Ventas[Categoria_Item] = "Producto"
    )
RETURN
    DATEDIFF(UltimaCompra, [Fecha Referencia RFM], DAY)
```
Días desde la última compra real del cliente.

### Frecuencia RFM
```dax
Frecuencia RFM = 
CALCULATE(
    DISTINCTCOUNT(Fact_Ventas[Invoice]),
    Fact_Ventas[Tipo_Transaccion] = "Venta",
    Fact_Ventas[Categoria_Item] = "Producto"
)
```
Número de facturas de venta real por cliente.

### Monto RFM
```dax
Monto RFM = [Ingresos Netos]
```
Gasto neto total del cliente (medida espejo de `Ingresos Netos`, nombrada así por legibilidad dentro de la lógica RFM).

### Puntaje Recencia / Frecuencia / Monto
```dax
Puntaje Recencia = 
VAR ClientesValidos = FILTER(ALL(Dim_Cliente), Dim_Cliente[Customer ID] <> 0)
VAR RankCliente = 
    RANKX(
        ClientesValidos,
        CALCULATE([Recencia (dias)]),
        ,
        ASC
    )
VAR TotalClientes = COUNTROWS(ClientesValidos)
RETURN
    IF(
        SELECTEDVALUE(Dim_Cliente[Customer ID]) = 0,
        BLANK(),
        6 - ROUNDUP(RankCliente * 5.0 / TotalClientes, 0)
    )
```
```dax
Puntaje Frecuencia = 
VAR ClientesValidos = FILTER(ALL(Dim_Cliente), Dim_Cliente[Customer ID] <> 0)
VAR RankCliente = 
    RANKX(
        ClientesValidos,
        CALCULATE([Frecuencia RFM]),
        ,
        DESC
    )
VAR TotalClientes = COUNTROWS(ClientesValidos)
RETURN
    IF(
        SELECTEDVALUE(Dim_Cliente[Customer ID]) = 0,
        BLANK(),
        6 - ROUNDUP(RankCliente * 5.0 / TotalClientes, 0)
    )
```
```dax
Puntaje Monto = 
VAR ClientesValidos = FILTER(ALL(Dim_Cliente), Dim_Cliente[Customer ID] <> 0)
VAR RankCliente = 
    RANKX(
        ClientesValidos,
        CALCULATE([Monto RFM]),
        ,
        DESC
    )
VAR TotalClientes = COUNTROWS(ClientesValidos)
RETURN
    IF(
        SELECTEDVALUE(Dim_Cliente[Customer ID]) = 0,
        BLANK(),
        6 - ROUNDUP(RankCliente * 5.0 / TotalClientes, 0)
    )
```
Convierten cada dimensión en un puntaje del 1 al 5 usando quintiles (`RANKX`), excluyendo al cliente sin identificar (`Customer ID = 0`). En Recencia, menos días = mejor puntaje (por eso `ASC`); en Frecuencia y Monto, más alto = mejor (por eso `DESC`).

### Segmento RFM
```dax
Segmento RFM = 
VAR R = [Puntaje Recencia]
VAR F = [Puntaje Frecuencia]
VAR M = [Puntaje Monto]
VAR Promedio = (R + F + M) / 3
RETURN
    IF(
        ISBLANK(R),
        BLANK(),
        SWITCH(
            TRUE(),
            R >= 4 && F >= 4 && M >= 4, "Campeones",
            R >= 4 && F <= 2, "Clientes Nuevos",
            R <= 2 && F >= 4 && M >= 4, "En Riesgo",
            R <= 2 && F <= 2 && M <= 2, "Perdidos",
            Promedio >= 3.5, "Leales",
            Promedio >= 2.5, "Potenciales",
            "Necesitan Atención"
        )
    )
```
Clasifica a cada cliente en uno de 7 segmentos, combinando los tres puntajes.

### Nº Clientes RFM / Campeones / En Riesgo
```dax
Nº Clientes RFM = 
CALCULATE(
    COUNTROWS(Dim_Cliente),
    Dim_Cliente[Customer ID] <> 0
)
```
```dax
Nº Clientes Campeones = 
CALCULATE(
    [Nº Clientes RFM],
    Dim_Cliente[Segmento RFM Col] = "Campeones"
)
```
```dax
Nº Clientes En Riesgo = 
CALCULATE(
    [Nº Clientes RFM],
    Dim_Cliente[Segmento RFM Col] = "En Riesgo"
)
```
Conteos de clientes, total y por segmento específico.

## Indicador de estado (explorado, no incluido en el dashboard final)

```dax
% Cancelado Promedio Historico = 
CALCULATE(
    [% Cancelado],
    ALL(Dim_Calendario)
)
```
```dax
Estado % Cancelado = 
VAR ValorActual = [% Cancelado]
VAR Promedio = [% Cancelado Promedio Historico]
RETURN
    IF(
        ISBLANK(ValorActual),
        BLANK(),
        IF(ValorActual <= Promedio, "🟢 Normal", "🔴 Alto")
    )
```
Compara el `% Cancelado` del período filtrado contra el promedio histórico del negocio completo. Se descartó del dashboard final por considerarse un elemento adicional no esencial, pero se documenta como parte del proceso de exploración.

## Columna calculada (no es medida)

Además de las medidas, se creó una **columna calculada** en la tabla `Dim_Cliente`, necesaria porque las medidas no pueden usarse como eje de categorías en un gráfico:

```dax
Segmento RFM Col = 
VAR ClienteActual = Dim_Cliente[Customer ID]
VAR R = CALCULATE([Puntaje Recencia], Dim_Cliente[Customer ID] = ClienteActual)
VAR F = CALCULATE([Puntaje Frecuencia], Dim_Cliente[Customer ID] = ClienteActual)
VAR M = CALCULATE([Puntaje Monto], Dim_Cliente[Customer ID] = ClienteActual)
VAR Promedio = (R + F + M) / 3
RETURN
    IF(
        ClienteActual = 0,
        BLANK(),
        SWITCH(
            TRUE(),
            R >= 4 && F >= 4 && M >= 4, "Campeones",
            R >= 4 && F <= 2, "Clientes Nuevos",
            R <= 2 && F >= 4 && M >= 4, "En Riesgo",
            R <= 2 && F <= 2 && M <= 2, "Perdidos",
            Promedio >= 3.5, "Leales",
            Promedio >= 2.5, "Potenciales",
            "Necesitan Atención"
        )
    )
```