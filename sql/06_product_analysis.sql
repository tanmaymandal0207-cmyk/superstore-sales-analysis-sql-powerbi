/* =====================================================================
   06 · PRODUCT ANALYSIS
   Business questions:
     Q1  Which products sell the most?
     Q2  Which products earn the best / worst margin?
     Q3  Which products lose money, and where is the loss concentrated?
   Grouping is by product_id: 17 product names are shared by more than one ID.
   ===================================================================== */

USE superstore;

-- Q1. Top 10 products by sales
SELECT
    p.product_id,
    p.product_name,
    p.category,
    ROUND(SUM(o.sales), 2)      AS total_sales,
    ROUND(SUM(o.profit), 2)     AS total_profit,
    SUM(o.quantity)             AS units_sold
FROM v_orders o
JOIN v_products p ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_sales DESC
LIMIT 10;

-- Q2. Margin by product (products with at least 1,000 in sales, to avoid tiny-base noise)
SELECT
    p.product_id,
    p.product_name,
    ROUND(SUM(o.sales), 2)                          AS total_sales,
    ROUND(SUM(o.profit), 2)                         AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales) * 100, 2)    AS profit_margin_pct
FROM v_orders o
JOIN v_products p ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(o.sales) >= 1000
ORDER BY profit_margin_pct DESC;

-- Q3a. Loss-making products (net profit < 0), largest loss first
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    ROUND(SUM(o.sales), 2)          AS total_sales,
    ROUND(SUM(o.profit), 2)         AS total_loss,
    ROUND(AVG(o.discount) * 100, 1) AS avg_discount_pct
FROM v_orders o
JOIN v_products p ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category, p.sub_category
HAVING SUM(o.profit) < 0
ORDER BY total_loss ASC;

-- Q3b. Loss concentration by category
WITH product_profit AS (
    SELECT p.category, o.product_id, SUM(o.profit) AS profit
    FROM v_orders o
    JOIN v_products p ON p.product_id = o.product_id
    GROUP BY p.category, o.product_id
)
SELECT
    category,
    COUNT(*)                    AS loss_products,
    ROUND(SUM(profit), 2)       AS total_loss
FROM product_profit
WHERE profit < 0
GROUP BY category
ORDER BY total_loss ASC;
