![IMAGEN](./picture/baneer%20vertical.png)

# Proyecto SQL: Analisís de Ventas de Walmart

## Introducción
El presente proyecto tiene como objetivo analizar las ventas de **Walmart**, una de las principales empresas minoristas a nivel mundial, durante el período 05/02/2010 al 26/10/2012, utilizando **SQL** dentro de **Databricks** para identificar tendencias y obtener insights relevantes.

## Sobre los datos

Los datos originales, junto con la información correspondiente a cada una de las columnas, están disponibles en este enlace de [Kaggle](https://www.kaggle.com/datasets/mikhail1681/walmart-sales).

La base de datos presenta 6,435 registros registrado con las siguientes columnas:

- Store: Número de tienda (bigint)
- Date: Fecha de inicio de la semana de ventas (date)
- Weekly_Sales: Ventas (double)
- Holiday_Flag: Indicador que señala si hay o no un día festivo (bigint)
- Temperature: Temperatura del aire en la región (double)
- Fuel_Price: Precio del combustible en la región (double)
- CPI: Índice de precios al consumo (double)
- Unemployment: Tasa de desempleo (double)

```sql
-- Muestra de la Base de Datos
select *
from walmart_sales.default.walmart_sales
```
![IMAGEN](./picture/01.%20Muestra%20de%20la%20Base%20de%20Datos.png)

```SQL
-- Descripción de las columnas en la Base de Datos
describe walmart_sales.default.walmart_sales
```
![IMAGEN](./picture/02.%20Descripción%20de%20las%20columnas%20en%20la%20Base%20de%20Datos.png)

## Tareas (Task)

En este análisis se busca responder lo siguiente:

  1. **Estructura**: Comprobar que la estructura de la base de datos.
  2. **Análisis de ventas**: ¿Cuánto vendió Walmart durante todo el periodo analizado?
  3. **Ranking de tiendas**: ¿Cuáles son las tiendas que generan más ingresos?
  4. **Ranking de tiendas - TOP 5**: ¿Cuál es la posición de cada tienda respecto a las demás?
  5. **Participación de cada tienda**: ¿Qué porcentaje de las ventas totales representa cada tienda?
  6. **Variación Porcentual Mensual**: Para cada tienda, ¿cuánto aumentaron o disminuyeron las ventas respecto al mes anterior?
  7. **Efecto de los Feriados**: ¿Las semanas festivas realmente generan mayores ventas?
  8. **Semanas de mayores ventas**: ¿Qué semanas presentan mayores ventas?
  9. **Ventas promedio según nivel de desempleo**: ¿Las tiendas presentan diferentes niveles de ventas cuando el desempleo es bajo, medio o alto?
 10. **Ventas promedio según precio del combustible**: ¿Cómo se comportan las ventas cuando el precio del combustible es bajo, medio o alto?

## Limpieza de datos
Se realizará la limpieza y validación de los datos para garantizar que estén completos, consistentes y listos para el análisis.

- Confirmación de duplicados
    
    ```SQL
    WITH CANTIDAD_REGISTROS AS (
        SELECT Store, Date, Count (*) as CANT_REGISTROS
        FROM walmart_sales.default.walmart_sales
        GROUP BY Store, Date
    )
    SELECT * 
    FROM cantidad_registros
    WHERE cant_registros > 1
    ```

    ![IMAGEN](./picture/03.%20Verificar%20si%20hay%20datos%20DUPLICADOS.png)

- Confirmación de nulos
    ```SQL
    SELECT
        COUNT(*) AS total_registros,
        COUNT(*) - COUNT(Store) AS nulos_store,
        COUNT(*) - COUNT(Date) AS nulos_date,
        COUNT(*) - COUNT(Weekly_Sales) AS nulos_weekly_sales,
        COUNT(*) - COUNT(Holiday_Flag) AS nulos_holiday_flag,
        COUNT(*) - COUNT(Temperature) AS nulos_temperature,
        COUNT(*) - COUNT(Fuel_Price) AS nulos_fuel_price,
        COUNT(*) - COUNT(CPI) AS nulos_cpi,
        COUNT(*) - COUNT(Unemployment) AS nulos_unemployment
    FROM walmart_sales.default.walmart_sales;
    ```
    ![IMAGEN](./picture/04.%20Verificar%20si%20hay%20datos%20NULOS.png)

## Análisis de Datos - Walmart_Sales.csv

### 1. Estructura de los datos: 
Comprobar la estructura de la base de datos.

```SQL
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT Store) AS total_stores,
    COUNT(DISTINCT Date) AS total_weeks,
    MIN(Date) AS first_date,
    MAX(Date) AS last_date,
    ROUND(SUM(Weekly_Sales),2) AS total_sales,
    ROUND(AVG(Weekly_Sales),2) AS avg_weekly_sales
FROM walmart_sales.default.walmart_sales;
```
![IMAGEN](./picture/05.%20Estructura%20de%20datos.png)

Se encontraron los siguientes datos:

- Número de registros: 6,435 registros
- Número de tiendas: 45 tiendas
- Número de semanas: 143
- Fecha inicial: 2010-02-05
- Fecha final: 2012-10-26
- Ventas totales: $ 6,737,218,987.11
- Venta semanal promedio: $ 1,046,964.88

### 2. Análisis de ventas: 
¿Cuánto vendió Walmart durante todo el periodo analizado?

```SQL
SELECT
    ROUND(SUM(Weekly_Sales),2) AS total_sales,
    ROUND(AVG(Weekly_Sales),2) AS avg_store_weekly_sales,
    ROUND(MIN(Weekly_Sales),2) AS min_weekly_sales,
    ROUND(MAX(Weekly_Sales),2) AS max_weekly_sales
FROM walmart_sales.default.walmart_sales;
```

![IMAGEN](./picture/06.%20Análisis%20de%20ventas.png)

Se obtubo los siguientes datos:

- Ventas totales: $ 6,737,218,987.11
- Promedio de Ventas Semanales: $ 1,046,964.88
- Venta mínima: $ 209,986.25
- Venta máxima: $ 3,818,686.45

### 3. Ranking de tiendas (Utilizando CTE): 

¿Cuáles son las tiendas que generan más ingresos?

```SQL
with store_sales as (
  select 
    Store, 
    sum(Weekly_Sales) as total_sales, 
    avg(Weekly_Sales) as avg_weekly_sales
  from walmart_sales.default.walmart_sales
  group by Store
)
select 
  store,
  total_sales,
  avg_weekly_sales
from store_sales
order by total_sales desc;
```

![IMAGEN](./picture/07.%20Ranking%20ventas.png)

Conclusióm:

- N° de Tienda con mayor ventas: N° 20
- N° de Tienda con menor ventas: N° 34

### 4. Ranking de tiendas - TOP 5 (Utilizando funciones de ventana): 

¿Cuál es la posición de cada tienda respecto a las demás?

```SQL
WITH RANKING AS (
  SELECT 
    Store,
    round(SUM(Weekly_Sales),2) AS Total_Sales
FROM walmart_sales.default.walmart_sales
GROUP BY Store
)
SELECT 
  store,
  total_sales,
  RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM RANKING
ORDER BY sales_rank
LIMIT 5;
```

![IMAGEN](./picture/08.%20Ranking.png)

### 5. Participación de cada tienda:

¿Qué porcentaje de las ventas totales representa cada tienda?

```SQL
with Store_Sales as (
  select 
    Store,
    Round(sum(Weekly_Sales),2) as Total_sales
  from walmart_sales.default.walmart_sales
  group by Store
), Company_Sales as (
  select 
    SUM(total_sales) as Company_Total_Sales
  from store_sales
  )
select 
    s.store,
    s.total_sales,
    round ((s.total_sales / c.company_total_sales * 100),2) AS Sales_Percentage
from store_sales s
Cross join company_sales c
order by sales_percentage desc;
```

![IMAGEN](./picture/09.%20Porcentaje%20de%20las%20ventas%20totales%20por%20cada%20tienda.png)

Esto permite identificar qué tiendas tienen mayor peso en el negocio.

### 6. Variación Porcentual Mensual:

Para cada tienda, ¿cuánto aumentaron o disminuyeron las ventas respecto al mes anterior?

```Sql
with Month_Sales as (
  select 
    Store,
    year(Date) as Year,
    month(Date) as Month,
    SUM(Weekly_Sales) as Month_Sales
  from walmart_sales.default.walmart_sales
  group by Store, year, month
), Pre_Month_Sale as (
    select 
      store,
      year,
      month,
      month_sales,
      lag(month_sales) over (partition by store order by year, month) as Pre_Month_Sale
    from month_sales
)
select 
  store,
  year,
  month, 
  round (((month_sales - pre_month_sale) / pre_month_sale * 100),2) as month_growth_pct
from pre_month_sale;
```

![IMAGEN](./picture/10.%20Variación%20mensual.png)

Se calcula la tasa porcentual de crecimiento por cada tienda durante el periodo comprendido desde Febrero 2010 a Octubre 2012.

### 7. Efecto de los Feriados:

¿Las semanas festivas realmente generan mayores ventas?

```SQL
SELECT 
  CASE
    WHEN Holiday_Flag = 1 THEN 'Holiday'
    ELSE 'Non-Holiday' END AS Period_Type,
  COUNT(*) AS Observation,
  ROUND(SUM(Weekly_Sales),2) AS Total_Sales,
  ROUND(AVG(Weekly_Sales),2) AS Avg_Sales
FROM walmart_sales.default.walmart_sales
GROUP BY Holiday_Flag;
```

![IMAGEN](./picture/11.%20Feriados.png)

Se obtiene lo siguiente

  - Promedio de venta semana normal = $ 1,041,256.38
  - Promedio de venta semana festiva = $ 1,122,887.89

Por tanto, las semanas festivas presentan en promedio ventas superiores.

### 8. Semanas de mayores ventas:

¿Qué semanas presentan mayores ventas?

```sql
WITH Weekly_Sales AS (
  SELECT 
    DATE,
    SUM(Weekly_Sales) AS Total_Week_Sales
  FROM walmart_sales.default.walmart_sales
  GROUP BY Date
),
Rank_Weeks as (
  select 
    DATE,
    total_week_sales,
    RANK() OVER (ORDER BY total_week_sales DESC) AS Rank_Sales
FROM weekly_sales
)
select 
  date,
  round(total_week_sales,2) AS Sales_Week,
  rank_sales
FROM rank_weeks
WHERE rank_sales <= 10;
```
![IMAGEN](./picture/12.%20Encontrar%20las%20semanas%20de%20mayor%20venta.png)

En la base de datos aparecen como semanas especialmente fuertes:

  - 24-12-2010
  - 23-12-2011
  - 25-11-2011
  - 26-11-2010

Las mayores ventas están fuertemente concentradas alrededor de periodos comerciales/festivos como Navidad y Black Friday.

### 9. Ventas promedio según nivel de desempleo:

¿Las tiendas presentan diferentes niveles de ventas cuando el desempleo es bajo, medio o alto?

```sql
with unemployment_stats as (
  select 
    ROUND(MAX(unemployment),2) as MAX_UNE,
    ROUND(min(unemployment),2) as MIN_UNE,
    ROUND(avg(unemployment),2) as AVG_UNE
  from walmart_sales.default.walmart_sales
)
select 
  CASE
    WHEN Unemployment < (us.MIN_UNE + us.AVG_UNE) / 2 THEN 'Low Unemployment'
    WHEN Unemployment < (us.MAX_UNE + us.AVG_UNE) / 2 THEN 'Medium Unemployment'
    ELSE 'High Unemployment' 
  END AS Unemployment_Level,
  ROUND(avg(ws.Weekly_Sales),2) as Avg_Week_Sales,
  Count(*) as Cant_Weeks
from walmart_sales.default.walmart_sales ws
cross join unemployment_stats us
group by 
  CASE
    WHEN Unemployment < (us.MIN_UNE + us.AVG_UNE) / 2 THEN 'Low Unemployment'
    WHEN Unemployment < (us.MAX_UNE + us.AVG_UNE) / 2 THEN 'Medium Unemployment'
    ELSE 'High Unemployment' 
  END
order by avg_week_sales;
```

![IMAGEN](./picture/14.%20Analizando%20ventas%20de%20acuerdo%20al%20desempleo.png)

Se puede tener como conclusión a mayor nivel de desempleo, las ventas promedio semanales disminuyen.

### 10. Ventas promedio según precio del combustible

¿Cómo se comportan las ventas cuando el precio del combustible es bajo, medio o alto?

```SQL
WITH Fuel_Stats AS (
  SELECT
    MIN(Fuel_Price) AS min_fp,
    AVG(Fuel_Price) AS avg_fp,
    MAX(Fuel_Price) AS max_fp
  FROM walmart_sales.default.walmart_sales
)
SELECT
    CASE
        WHEN Fuel_Price < (s.min_fp + s.avg_fp) / 2 THEN 'Low Fuel Price'
        WHEN Fuel_Price < (s.avg_fp + s.max_fp) / 2 THEN 'Medium Fuel Price'
        ELSE 'High Fuel Price'
    END AS fuel_price_level,
    ROUND(AVG(Weekly_Sales), 2) AS avg_week_sales,
    COUNT(*) AS Cant_Weeks
FROM walmart_sales.default.walmart_sales
CROSS JOIN Fuel_Stats s
GROUP BY
    CASE
        WHEN Fuel_Price < (s.min_fp + s.avg_fp) / 2 THEN 'Low Fuel Price'
        WHEN Fuel_Price < (s.avg_fp + s.max_fp) / 2 THEN 'Medium Fuel Price'
        ELSE 'High Fuel Price'
    END
ORDER BY avg_week_sales DESC;
```

![IMAGEN](./picture/15.%20Ventas%20promedio%20según%20precio%20del%20combustible.png)

A diferencia de la consulta anterior, a mayor precio del combustible, se registra un ligero incremento en las ventas semanales promedio.

## Conclusión:

  - **Análisis de tiendas con bajo rendimiento**: Realizar un análisis de las tiendas con menores niveles de ventas (como la tienda N.° 34), tomando como referencia las buenas prácticas de las tiendas con mejor desempeño (como la tienda N.° 20). Evaluar factores externos e internos, tales como la ubicación, la variedad de productos ofrecidos, la competencia local y la gestión operativa, con el objetivo de identificar oportunidades de mejora y diseñar planes de acción que permitan incrementar las ventas y mejorar el rendimiento de las tiendas.
  - **Programas durante las semanas regulares**: Para reducir la diferencia de ventas entre las semanas festivas y las habituales, es recomendable desarrollar estrategias comerciales intermedias, como ventas nocturnas, jornadas exclusivas para miembros y promociones estacionales, que permitan generar ingresos estables durante todo el año.
  - **Optimización de inventario en temporadas festivas**: Dado que en campañas de Navidad y Black Firday presentan picos altos de facturación, Walmart debe anticipar la demanda, optimizando la logística y el personal para garantizar el stock suficiente de productos de alta demanda.
  - **Estrategias comerciales en periodos de mayor desempleo**: Ante la caída en las ventas semanales durante periodos con mayor desempleo, se recomienda implementar campañas de promociones, descuentos y opciones de financiamiento en tiendas situadas en zonas de menor ingreso. Estas medidas. Estas medidas buscan mitigar el impacto de la reducción del poder adquisitivo y la mayor sensibilidad de los consumidores al precio.
  - **Estrategia ante bajo impacto al precio del combustible**: Dado que el incremento en el precio del combustible no afecta negativamente el volumen de ventas, se recomienda mantener la oferta de productos y evitar descuentos innecesarios. Esta estrategia permitirá preservar los márgenes de rentabilidad, sin comprometer el desempeño comercial.