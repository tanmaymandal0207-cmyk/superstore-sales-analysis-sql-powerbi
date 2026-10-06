/* =====================================================================
   03 · DATA CLEANING
   Non-destructive: the raw tables are left untouched and every analysis
   script reads from these views instead. Re-running is always safe.

   v_orders    – typed order & ship dates, delivery days, year/month keys
   v_customers – one row per customer_id
   v_products  – one row per product_id
   ===================================================================== */

USE superstore;

CREATE OR REPLACE VIEW v_orders AS
SELECT
    o.order_id,
    STR_TO_DATE(o.order_date, '%d-%m-%Y')                          AS order_date,
    STR_TO_DATE(o.ship_date,  '%d-%m-%Y')                          AS ship_date,
    DATEDIFF(STR_TO_DATE(o.ship_date,  '%d-%m-%Y'),
             STR_TO_DATE(o.order_date, '%d-%m-%Y'))                AS delivery_days,
    YEAR(STR_TO_DATE(o.order_date, '%d-%m-%Y'))                    AS order_year,
    DATE_FORMAT(STR_TO_DATE(o.order_date, '%d-%m-%Y'), '%Y-%m')    AS order_month,
    TRIM(o.ship_mode)                                              AS ship_mode,
    TRIM(o.customer_id)                                            AS customer_id,
    TRIM(o.product_id)                                             AS product_id,
    o.sales,
    o.quantity,
    o.discount,
    o.profit
FROM orders o;

CREATE OR REPLACE VIEW v_customers AS
SELECT
    TRIM(customer_id)  AS customer_id,
    MIN(customer_name) AS customer_name,
    MIN(segment)       AS segment,
    MIN(city)          AS city,
    MIN(state)         AS state,
    MIN(region)        AS region
FROM customers
GROUP BY TRIM(customer_id);

CREATE OR REPLACE VIEW v_products AS
SELECT
    TRIM(product_id)   AS product_id,
    MIN(product_name)  AS product_name,
    MIN(category)      AS category,
    MIN(sub_category)  AS sub_category
FROM products
GROUP BY TRIM(product_id);

-- Validation: views must keep every order line and resolve every key
SELECT
    (SELECT COUNT(*) FROM orders)                                AS raw_lines,
    (SELECT COUNT(*) FROM v_orders)                              AS view_lines,
    (SELECT COUNT(*) FROM v_orders WHERE order_date IS NULL)     AS unparsed_dates,
    (SELECT COUNT(*) FROM v_orders o
       LEFT JOIN v_customers c USING (customer_id)
      WHERE c.customer_id IS NULL)                               AS unmatched_customers,
    (SELECT COUNT(*) FROM v_orders o
       LEFT JOIN v_products p USING (product_id)
      WHERE p.product_id IS NULL)                                AS unmatched_products;
