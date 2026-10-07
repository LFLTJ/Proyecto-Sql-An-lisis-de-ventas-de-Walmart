![IMAGEN](./picture/baneer%20vertical.png)

# Proyecto SQL: Analisís de ventas de Walmart

## Introducción
El presente proyecto tiene como objetivo analizar las ventas de Walmart, una de las principales empresas minoristas a nivel mundial, durante el período 05/02/2010 al 26/10/2012, utilizando SQL en Databricks para identificar tendencias y obtener insights relevantes.

## Estructura del Proyecto

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
Comprobar que la estructura de la base de datos.

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
- N° de Tienda con menoor ventas: N° 34

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

### 5. Participación de cada tienda

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




























