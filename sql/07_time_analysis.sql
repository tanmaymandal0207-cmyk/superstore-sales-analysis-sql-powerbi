/* =====================================================================
   07 · TIME-BASED ANALYSIS
   Business questions:
     Q1  How are sales and profit trending year over year?
     Q2  What does the monthly trend look like?
     Q3  Which calendar months are strongest (seasonality)?
   ===================================================================== */

USE superstore;

-- Q1. Yearly sales, profit, margin and YoY growth
WITH yearly AS (
    SELECT
        order_year,
        SUM(sales)                  AS sales,
        SUM(profit)                 AS profit,
        COUNT(DISTINCT order_id)    AS orders
    FROM v_orders
    GROUP BY order_year
)
SELECT
    order_year,
    ROUND(sales, 2)                                                 AS total_sales,
    ROUND(profit, 2)                                                AS total_profit,
    ROUND(profit / sales * 100, 2)                                  AS profit_margin_pct,
    orders,
    ROUND((sales - LAG(sales) OVER (ORDER BY order_year))
          / LAG(sales) OVER (ORDER BY order_year) * 100, 2)         AS sales_yoy_pct
FROM yearly
ORDER BY order_year;

-- Q2. Monthly trend with a 3-month moving average
WITH monthly AS (
    SELECT order_month, SUM(sales) AS sales, SUM(profit) AS profit
    FROM v_orders
    GROUP BY order_month
)
SELECT
    order_month,
    ROUND(sales, 2)                                                         AS total_sales,
    ROUND(profit, 2)                                                        AS total_profit,
    ROUND(AVG(sales) OVER (ORDER BY order_month
                           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)   AS sales_3m_avg
FROM monthly
ORDER BY order_month;

-- Q3. Seasonality: share of sales by calendar month (all years combined)
SELECT
    MONTH(order_date)                                           AS month_no,
    MONTHNAME(MIN(order_date))                                  AS month_name,
    ROUND(SUM(sales), 2)                                        AS total_sales,
    ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER (), 2)        AS sales_share_pct
FROM v_orders
GROUP BY MONTH(order_date)
ORDER BY month_no;
