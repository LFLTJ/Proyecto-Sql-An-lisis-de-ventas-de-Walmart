-- Mi primera consulta
-- Muestra de la Base de Datos
select *
from walmart_sales.default.walmart_sales;

--Descripción de las columnas en la Base de Datos
describe walmart_sales.default.walmart_sales;

-- Total de registros
select
  count (*)
from walmart_sales.default.walmart_sales;

-- Verificar si hay datos DUPLICADOS
WITH CANTIDAD_REGISTROS AS (
   SELECT Store, Date, Count (*) as CANT_REGISTROS
   FROM walmart_sales.default.walmart_sales
   GROUP BY Store, Date
)
SELECT *
FROM cantidad_registros
WHERE cant_registros > 1;

-- Verificar si hay datos NULOS
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

--1. Estructura de datos
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT Store) AS total_stores,
    COUNT(DISTINCT Date) AS total_weeks,
    MIN(Date) AS first_date,
    MAX(Date) AS last_date,
    ROUND(SUM(Weekly_Sales),2) AS total_sales,
    ROUND(AVG(Weekly_Sales),2) AS avg_weekly_sales
FROM walmart_sales.default.walmart_sales;

--2. Análisis de ventas
SELECT
    ROUND(SUM(Weekly_Sales),2) AS total_sales,
    ROUND(AVG(Weekly_Sales),2) AS avg_store_weekly_sales,
    ROUND(MIN(Weekly_Sales),2) AS min_weekly_sales,
    ROUND(MAX(Weekly_Sales),2) AS max_weekly_sales
FROM walmart_sales.default.walmart_sales;

--3 Ranking de tiendas
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

--4 TOP 5
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

--5 Porcentaje de las ventas totales por cada tienda
with Store_Sales as (
  select 
    Store,
    Round(sum(Weekly_Sales),2) as Total_sales
  from walmart_sales.default.walmart_sales
  group by Store
),
Company_Sales as (
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

