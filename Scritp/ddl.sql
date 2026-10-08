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

--6. Variación Porcentual Mensual
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
from pre_month_sale
;

--7. Efecto de Feriados
SELECT 
  CASE
    WHEN Holiday_Flag = 1 THEN 'Holiday'
    ELSE 'Non-Holiday' END AS Period_Type,
  COUNT(*) AS Observation,
  ROUND(SUM(Weekly_Sales),2) AS Total_Sales,
  ROUND(AVG(Weekly_Sales),2) AS Avg_Sales
FROM walmart_sales.default.walmart_sales
GROUP BY Holiday_Flag;

--8. Encontrar las semanas de mayor venta
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

--9. Ventas promedio según nivel de desempleo:
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
order by avg_week_sales
;

--10. Ventas promedio según precio del combustible
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
    ROUND(AVG(ws.Weekly_Sales), 2) AS avg_week_sales,
    COUNT(*) AS Cant_Weeks
FROM walmart_sales.default.walmart_sales ws
CROSS JOIN Fuel_Stats s
GROUP BY
    CASE
        WHEN Fuel_Price < (s.min_fp + s.avg_fp) / 2 THEN 'Low Fuel Price'
        WHEN Fuel_Price < (s.avg_fp + s.max_fp) / 2 THEN 'Medium Fuel Price'
        ELSE 'High Fuel Price'
    END
ORDER BY avg_week_sales;