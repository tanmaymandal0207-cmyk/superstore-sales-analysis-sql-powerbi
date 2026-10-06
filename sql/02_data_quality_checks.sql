/* =====================================================================
   02 · DATA QUALITY CHECKS
   Run after loading. Every check returns a single number or a short
   list; anything unexpected is resolved in 03_data_cleaning.sql.
   ===================================================================== */

USE superstore;

-- 1. Volume overview: order lines vs distinct orders, customers, products
SELECT
    COUNT(*)                    AS order_lines,
    COUNT(DISTINCT order_id)    AS distinct_orders,
    COUNT(DISTINCT customer_id) AS distinct_customers,
    COUNT(DISTINCT product_id)  AS distinct_products
FROM orders;

-- 2. Duplicate keys in the dimension tables (must be 0 before joining)
SELECT 'customers' AS table_name, COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_keys FROM customers
UNION ALL
SELECT 'products',  COUNT(*) - COUNT(DISTINCT product_id) FROM products;

-- 3. Exact duplicate order lines (same values in every column)
SELECT
    order_id, product_id, order_date, sales, quantity, discount, profit,
    COUNT(*) AS copies
FROM orders
GROUP BY order_id, product_id, order_date, ship_date, ship_mode,
         customer_id, sales, quantity, discount, profit
HAVING COUNT(*) > 1;

-- 4. Orphan keys: order lines with no matching customer / product
SELECT
    SUM(c.customer_id IS NULL) AS orders_without_customer,
    SUM(p.product_id  IS NULL) AS orders_without_product
FROM orders o
LEFT JOIN (SELECT DISTINCT customer_id FROM customers) c ON c.customer_id = o.customer_id
LEFT JOIN (SELECT DISTINCT product_id  FROM products)  p ON p.product_id  = o.product_id;

-- 5. Nulls / blanks in critical columns
SELECT
    SUM(order_id   IS NULL OR order_id   = '') AS blank_order_id,
    SUM(order_date IS NULL OR order_date = '') AS blank_order_date,
    SUM(sales      IS NULL)                    AS null_sales,
    SUM(profit     IS NULL)                    AS null_profit
FROM orders;

-- 6. Dates that will not parse as dd-mm-yyyy
SELECT order_id, order_date, ship_date
FROM orders
WHERE STR_TO_DATE(order_date, '%d-%m-%Y') IS NULL
   OR STR_TO_DATE(ship_date,  '%d-%m-%Y') IS NULL;

-- 7. Range sanity
SELECT
    MIN(sales)    AS min_sales,    MAX(sales)    AS max_sales,
    MIN(discount) AS min_discount, MAX(discount) AS max_discount,
    MIN(quantity) AS min_qty,      MAX(quantity) AS max_qty
FROM orders;

-- 8. Same name used by different customer IDs (why analysis groups by ID, not name)
SELECT customer_name, COUNT(DISTINCT customer_id) AS ids
FROM customers
GROUP BY customer_name
HAVING COUNT(DISTINCT customer_id) > 1;
