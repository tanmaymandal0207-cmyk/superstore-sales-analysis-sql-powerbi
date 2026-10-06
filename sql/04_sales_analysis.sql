/* =====================================================================
   04 · SALES ANALYSIS
   Business questions:
     Q1  What are the headline KPIs?
     Q2  Which regions drive sales, and at what margin?
     Q3  Which categories / sub-categories drive sales and profit?
   ===================================================================== */

USE superstore;

-- Q1. Headline KPIs
--     AOV is per ORDER (distinct order_id), not per order line.
SELECT
    ROUND(SUM(sales), 2)                                AS total_sales,
    ROUND(SUM(profit), 2)                               AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)            AS profit_margin_pct,
    COUNT(DISTINCT order_id)                            AS total_orders,
    COUNT(*)                                            AS order_lines,
    SUM(quantity)                                       AS units_sold,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)     AS avg_order_value
FROM v_orders;

-- Q2. Sales, profit and margin by region
SELECT
    c.region,
    ROUND(SUM(o.sales), 2)                                          AS total_sales,
    ROUND(SUM(o.profit), 2)                                         AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales) * 100, 2)                    AS profit_margin_pct,
    ROUND(SUM(o.sales) * 100 / SUM(SUM(o.sales)) OVER (), 2)        AS sales_share_pct
FROM v_orders o
JOIN v_customers c ON c.customer_id = o.customer_id
GROUP BY c.region
ORDER BY total_sales DESC;

-- Q3a. Category performance
SELECT
    p.category,
    ROUND(SUM(o.sales), 2)                                          AS total_sales,
    ROUND(SUM(o.profit), 2)                                         AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales) * 100, 2)                    AS profit_margin_pct,
    ROUND(SUM(o.sales) * 100 / SUM(SUM(o.sales)) OVER (), 2)        AS sales_share_pct
FROM v_orders o
JOIN v_products p ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

-- Q3b. Sub-category performance, worst margin first
SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(o.sales), 2)                          AS total_sales,
    ROUND(SUM(o.profit), 2)                         AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales) * 100, 2)    AS profit_margin_pct
FROM v_orders o
JOIN v_products p ON p.product_id = o.product_id
GROUP BY p.category, p.sub_category
ORDER BY profit_margin_pct ASC;
