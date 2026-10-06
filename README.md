![IMAGEN](./picture/baneer%20vertical.png)

# Proyecto SQL: Analisís de ventas de Walmart

## Introducción
El presente proyecto tiene como objetivo analizar las ventas de Walmart, una de las principales empresas minoristas a nivel mundial, durante el período 2010-2012, utilizando SQL en Databricks para identificar tendencias y obtener insights relevantes.

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
































