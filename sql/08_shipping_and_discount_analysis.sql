/* =====================================================================
   08 · SHIPPING & DISCOUNT ANALYSIS
   Business questions:
     Q1  How long does delivery take, overall and by ship mode?
     Q2  How does discount level affect profit?
     Q3  At which discount band does the business start losing money?
   ===================================================================== */

USE superstore;

-- Q1a. Average delivery time
SELECT ROUND(AVG(delivery_days), 2) AS avg_delivery_days
FROM v_orders;

-- Q1b. Delivery time and volume by ship mode
SELECT
    ship_mode,
    COUNT(DISTINCT order_id)                        AS orders,
    ROUND(AVG(delivery_days), 2)                    AS avg_delivery_days,
    MAX(delivery_days)                              AS max_delivery_days,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)        AS profit_margin_pct
FROM v_orders
GROUP BY ship_mode
ORDER BY avg_delivery_days;

-- Q2. Profit by exact discount level
SELECT
    discount,
    COUNT(*)                                        AS order_lines,
    ROUND(SUM(sales), 2)                            AS total_sales,
    ROUND(AVG(profit), 2)                           AS avg_profit_per_line,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)        AS profit_margin_pct
FROM v_orders
GROUP BY discount
ORDER BY discount;

-- Q3. Discount bands
SELECT
    CASE
        WHEN discount = 0     THEN '1. No discount'
        WHEN discount <= 0.20 THEN '2. 1% - 20%'
        WHEN discount <= 0.40 THEN '3. 21% - 40%'
        ELSE                       '4. Above 40%'
    END                                             AS discount_band,
    COUNT(*)                                        AS order_lines,
    ROUND(SUM(sales), 2)                            AS total_sales,
    ROUND(SUM(profit), 2)                           AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)        AS profit_margin_pct
FROM v_orders
GROUP BY discount_band
ORDER BY discount_band;
