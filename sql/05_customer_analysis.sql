/* =====================================================================
   05 · CUSTOMER ANALYSIS
   Business questions:
     Q1  Who are the top 10 customers?
     Q2  What is each customer's lifetime value and average order value?
     Q3  How do customers split into value segments?
     Q4  How many customers buy more than once?
     Q5  How do customers rank by spend?
   All grouping is by customer_id: one customer name maps to 5 different IDs.
   ===================================================================== */

USE superstore;

-- Q1. Top 10 customers by spend
SELECT
    c.customer_id,
    c.customer_name,
    c.region,
    ROUND(SUM(o.sales), 2)      AS total_spent,
    COUNT(DISTINCT o.order_id)  AS orders
FROM v_orders o
JOIN v_customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.region
ORDER BY total_spent DESC
LIMIT 10;

-- Q2. Lifetime value and AOV per customer
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(o.sales), 2)                              AS lifetime_value,
    ROUND(SUM(o.profit), 2)                             AS lifetime_profit,
    COUNT(DISTINCT o.order_id)                          AS orders,
    ROUND(SUM(o.sales) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM v_orders o
JOIN v_customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY lifetime_value DESC;

-- Q3. Value segmentation (thresholds on lifetime sales)
WITH customer_spend AS (
    SELECT customer_id, SUM(sales) AS total_spent
    FROM v_orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_spent >  5000 THEN 'High Value (> 5,000)'
        WHEN total_spent >= 2000 THEN 'Mid Value (2,000 - 5,000)'
        ELSE                          'Low Value (< 2,000)'
    END                                                     AS customer_segment,
    COUNT(*)                                                AS customers,
    ROUND(SUM(total_spent), 2)                              AS segment_sales,
    ROUND(SUM(total_spent) * 100 / SUM(SUM(total_spent)) OVER (), 2) AS sales_share_pct
FROM customer_spend
GROUP BY customer_segment
ORDER BY segment_sales DESC;

-- Q4. Repeat vs one-time customers (counted on DISTINCT orders, not order lines)
WITH customer_orders AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS orders
    FROM v_orders
    GROUP BY customer_id
)
SELECT
    CASE WHEN orders = 1 THEN 'One-time' ELSE 'Repeat' END  AS customer_type,
    COUNT(*)                                                AS customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)      AS pct_of_customers
FROM customer_orders
GROUP BY customer_type;

-- Q5. Spend ranking
SELECT
    customer_id,
    ROUND(total_sales, 2)                               AS total_sales,
    DENSE_RANK() OVER (ORDER BY total_sales DESC)       AS spend_rank,
    ROUND(PERCENT_RANK() OVER (ORDER BY total_sales) * 100, 1) AS percentile
FROM (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM v_orders
    GROUP BY customer_id
) AS cs
ORDER BY spend_rank;
